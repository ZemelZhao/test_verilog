module top(
    input clk,
    input rgmii_rxc,
    output rgmii_txc,

    input key,
    output e_mdc,
    input e_mdio,
    input rgmii_rxctl,
    output rgmii_txctl,
    input [3:0] rgmii_rxd,
    output [3:0] rgmii_txd,

    output [15:0] led
);

    localparam VERSION = 8'h05;
    assign led[15:8] = ~VERSION;

    wire gmii_rxc, gmii_txc;
    wire gmii_rxdv, gmii_txen;
    wire [7:0] gmii_rxd, gmii_txd;

    wire sys_clk;

// MAC
    localparam  SOURCE_MAC_ADDR = 48'h00_0A_35_01_FE_C0;
    localparam  SOURCE_IP_ADDR = 32'hC0_A8_00_02;
    localparam  SOURCE_PORT = 32'd8080;
    localparam  DESTINATION_IP_ADDR = 32'hC0_A8_00_03;
    localparam  DESTINATION_PORT = 32'd8080;
    localparam  MAC_TTL = 8'h80;

    wire mac_rxdv, mac_txdv;
    wire [7:0] mac_rxd, mac_txd;
    wire fs_udp_rx, fs_udp_tx;
    wire fd_udp_rx, fd_udp_tx;
    wire fs_mac2fifoc, fd_mac2fifoc;
    wire fs_fifoc2cs, fd_fifoc2cs;
    wire fs_fw, fd_fw;
    wire [7:0] udp_rxd, udp_txd;
    wire flag_udp_tx_req, flag_udp_tx_prep;
    wire udp_txen;
    wire [10:0] udp_rx_addr;
    wire [15:0] udp_rx_len;
    wire [11:0] eth_rx_len;
    wire [15:0] eth_tx_len;
    wire [9:0] adc_rx_len;
    wire [7:0] adc_cnt;
    wire [7:0] fifo_part; 
    
// FIFO
    wire fifod_rxc, fifod_txc;
    wire fifod_rxen, fifod_txen;
    wire [7:0] fifod_rxd, fifod_txd;
    wire fifod_empty, fifod_full;
    
    wire fifoc_rxen, fifoc_txen;
    wire [7:0] fifoc_rxd, fifoc_txd;
    wire fifoc_empty, fifoc_full;

    wire err_fifoc2cs;

    wire [7:0] kind_dev, info_sr, cmd_filt, cmd_mix0;
    wire [7:0] cmd_mix1, cmd_reg4, cmd_reg5, cmd_reg6;
    wire [7:0] cmd_reg7;


    wire rst;
    wire fs_key;
    reg [7:0] state, next_state;
    localparam IDLE = 8'h0, FITX = 8'h1, FIMC = 8'h2, LAST = 8'h3;

    assign fs_fw = (state == FITX);
    assign fs_udp_tx = (state == FIMC);
    assign fifo_part = 8'h0D;
    assign eth_tx_len = 16'h0020;



    always @(posedge sys_clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(fs_key) next_state <= FITX;
                else next_state <= IDLE;
            end
            FITX: begin
                if(fd_fw) next_state <= FIMC;
                else next_state <= FITX;
            end
            FIMC: begin
                if(fd_udp_tx) next_state <= LAST;
                else next_state <= FIMC;
            end
            LAST: begin
                if(~fs_key) next_state <= IDLE;
                else next_state <= LAST;
            end
            default: next_state <= IDLE;
        endcase
    end




    eth 
    eth_dut(
        .e_mdc(e_mdc),
        .e_mdio(e_mdio),
        .rgmii_txd(rgmii_txd),
        .rgmii_txctl(rgmii_txctl),
        .rgmii_txc(rgmii_txc),
        .rgmii_rxd(rgmii_rxd),
        .rgmii_rxctl(rgmii_rxctl),
        .gmii_txc(gmii_txc),
        .gmii_rxc(gmii_rxc),
        .gmii_rxdv(gmii_rxdv),
        .gmii_rxd(gmii_rxd),
        .gmii_txen(gmii_txen),
        .gmii_txd(gmii_txd)
    );

    mac 
    mac_dut(
        .gmii_txc(gmii_txc),
        .gmii_rxc(gmii_rxc),
        .rst(),
        .mac_ttl(MAC_TTL),
        .src_mac_addr(SOURCE_MAC_ADDR),
        .src_ip_addr(SOURCE_IP_ADDR),
        .src_port(SOURCE_PORT),
        .det_ip_addr(DESTINATION_IP_ADDR),
        .det_port(DESTINATION_PORT),
        .mac_rxdv(mac_rxdv),
        .mac_rxd(mac_rxd),
        .mac_txdv(mac_txdv),
        .mac_txd(mac_txd),
        .fs_udp_tx(fs_udp_tx),
        .fd_udp_tx(fd_udp_tx),
        .udp_tx_len(eth_tx_len),
        .flag_udp_tx_req(flag_udp_tx_req),
        .udp_txen(udp_txen),
        .flag_udp_tx_prep(flag_udp_tx_prep),
        .udp_txd(udp_txd),
        .fs_udp_rx(fs_udp_rx),
        .fd_udp_rx(fd_udp_rx),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(eth_rx_len),
        .so()
    );

    cs
    cs_dut(
        .osc_clk(clk),
        .net_clk(rgmii_rxc),
        .sys_clk(sys_clk),
        .eth_clk(gmii_rxc)
    );

    fifod
    fifod_dut(
        .rst(),

        .wr_clk(sys_clk),
        .din(fifod_txd),
        .wr_en(fifod_txen),

        .rd_clk(gmii_txc),
        .rd_en(fifod_rxen),
        .dout(fifod_rxd),

        .full(fifod_full)
    );

    fifoc
    fifoc_dut(
        .rst(),

        .wr_clk(gmii_rxc),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),

        .rd_clk(sys_clk),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen),

        .full(fifoc_full)
    );

    fifod2mac 
    fifod2mac_dut(
        .clk(gmii_txc),
        .rst(rst),
        .fs(fs_udp_tx),
        .fd(fd_udp_tx),
        .data_len(eth_tx_len),
        .fifod_rxen(fifod_rxen),
        .fifod_rxd(fifod_rxd),
        .udp_txen(udp_txen),
        .udp_txd(udp_txd),
        .flag_udp_tx_prep(flag_udp_tx_prep),
        .flag_udp_tx_req(flag_udp_tx_req)
    );

    fifoc2cs
    fifoc2cs_dut(
        .clk(sys_clk),
        .rst(rst),
        .err(err_fifoc2cs),
        .fs(fs_fifoc2cs),
        .fd(fd_fifoc2cs),
        .fifoc_rxen(fifoc_rxen),
        .fifoc_rxd(fifoc_rxd),
        .data_len(eth_rx_len),
        .kind_dev(kind_dev),
        .info_sr(info_sr),
        .cmd_filt(cmd_filt),
        .cmd_mix0(cmd_mix0),
        .cmd_mix1(cmd_mix1),
        .cmd_reg4(cmd_reg4),
        .cmd_reg5(cmd_reg5),
        .cmd_reg6(cmd_reg6),
        .cmd_reg7(cmd_reg7)
    );

    eth2mac
    eth2mac_dut(
        .rst(),
        .gmii_txc(gmii_txc),
        .gmii_rxc(gmii_rxc),
        .gmii_rxdv(gmii_rxdv),
        .gmii_rxd(gmii_rxd),
        .mac_rxdv(mac_rxdv),
        .mac_rxd(mac_rxd),
        .gmii_txen(gmii_txen),
        .gmii_txd(gmii_txd),
        .mac_txdv(mac_txdv),
        .mac_txd(mac_txd)
    );

    mac2fifoc 
    mac2fifoc_dut(
        .clk(gmii_rxc),
        .rst(),
        .fs(fs_mac2fifoc),
        .fd(fd_mac2fifoc),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifoc_txd),
        .fifoc_txen(fifoc_txen),
        .dev_rx_len(eth_rx_len)
    );

    fifo_write 
    fifo_write_dut(
        .clk(sys_clk),
        .rst(rst),
        .err(),
        .fifo_txd(fifod_txd),
        .fifo_txen(fifod_txen),
        .fs(fs_fw),
        .fd(fd_fw),
        .data_len(eth_tx_len),
        .fifo_full(fifod_full),
        .part(fifo_part)
    );


    key
    key_dut(
        .clk(sys_clk),
        .key(key),
        .fs(fs_key)
    );

endmodule