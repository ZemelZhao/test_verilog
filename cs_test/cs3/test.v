module top(
    input sys_clk,

    input rst_n,
    input [1:0] key,
    output [3:0] lec,
    output [31:0] led,

    input rgmii_rxc,
    output rgmii_txc,
    output e_mdc,
    input e_mdio,
    output rgmii_txctl,
    output [3:0] rgmii_txd,
    input rgmii_rxctl,
    input [3:0] rgmii_rxd
);


// MAC SECTION
    localparam LED_NUM = 8'h11;
// #region
    localparam SOURCE_MAC_ADDR = 48'h00_0A_35_01_FE_C0;
    localparam SOURCE_IP_ADDR = 32'hC0_A8_00_02;
    localparam SOURCE_PORT = 16'h1F90;
    localparam DESTINATION_IP_ADDR = 32'hC0_A8_00_03;
    localparam DESTINATION_PORT = 16'h1F90;
    localparam MAC_TTL = 8'h80;

    wire gmii_txc, gmii_rxc;
    wire gmii_rxdv, gmii_txen;
    wire [7:0] gmii_rxd, gmii_txd;

    wire mac_rxdv, mac_txdv;
    wire [7:0] mac_rxd, mac_txd;

    wire [15:0] udp_rx_len;
    wire [10:0] udp_rx_addr;
    wire udp_txen;
    wire [7:0] udp_txd;
    wire [7:0] udp_rxd;
    wire [11:0] eth_rx_len;
    wire [11:0] eth_tx_len;
    wire [9:0] adc_rx_len;
    wire flag_udp_tx_req, flag_udp_tx_prep;


    wire fs_udp_tx, fd_udp_tx;
    wire fs_udp_rx, fd_udp_rx;

    wire [7:0] fifoc_txd, fifoc_rxd;
    wire [7:0] fifod_txd, fifod_rxd;
    wire fifoc_txen, fifoc_rxen;
    wire fifod_txen, fifod_rxen;

    wire fifoc_full, fifod_full;
    wire [3:0] num;
    wire fsu, fsd, fdu, fdd;
    wire fs_fw, fd_fw;
    wire [7:0] led_cont, kind_dev, info_sr, cmd_filt;
    wire [7:0] cmd_mix0, cmd_mix1;
    wire [7:0] cmd_reg4, cmd_reg5, cmd_reg6, cmd_reg7;

    wire [7:0] so_fifoc2cs;
    wire rst;

    wire fs_mac2fifoc, fd_mac2fifoc;
    wire fs_fifoc2cs, fd_fifoc2cs;
    reg [3:0] fw_cmd;

    localparam WAIT_PAR = 32'd100_000_000;
    reg [31:0] wait_num;

    reg [7:0] state, next_state;

    localparam IDL0 = 8'h00, IDL1 = 8'h01;
    localparam WAIT = 8'h02, NAP0 = 8'h03;
    localparam RMTX = 8'h04, RMRX = 8'h05;

    assign fs_fw = (state == RMTX);
    assign fs_fifoc2cs = (state == RMRX);
    assign rst = ~rst_n;
    assign num = 4'h2;

    assign fifod_txen = 1'b0;
    assign fifod_rxen = 1'b0;


    always @(posedge sys_clk or posedge rst) begin
        if(rst) state <= IDL0;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDL0: begin
                if(~|{fifoc_full, fifod_full}) next_state <= WAIT;
                else next_state <= IDL0;
            end
            IDL1: begin
                next_state <= WAIT;
            end
            WAIT: begin
                if(wait_num == WAIT_PAR) next_state <= RMTX;
                else next_state <= WAIT;
            end
            RMTX: begin
                if(fd_fw) next_state <= NAP0;
                else next_state <= RMTX;
            end
            NAP0: begin
                next_state <= RMRX;
            end
            RMRX: begin
                if(fd_fifoc2cs) next_state <= IDL1;
                else next_state <= RMRX;
            end
        endcase
    end

    always@(posedge sys_clk or posedge rst) begin
        if(rst) wait_num <= 32'h0;
        else if(state == IDL0 || state == IDL1) wait_num <= 32'h0;
        else if(state == WAIT) wait_num <= wait_num + 1'b1;
        else wait_num <= wait_num;
    end

    always @(posedge sys_clk or posedge rst) begin
        if(rst) fw_cmd <= 4'h0;
        else if(state == IDL0) fw_cmd <= 4'h0;
        else if(state == IDL1 && fw_cmd == 4'h5) fw_cmd <= 4'h0;
        else if(state == IDL1 && fw_cmd != 4'h5) fw_cmd <= fw_cmd + 1'b1;
        else fw_cmd <= fw_cmd;  
    end
    

// MAC
// # region
    eth 
    eth_dut(
        .e_mdc(e_mdc),
        .e_mdio(e_mdio),
        .rgmii_txd(rgmii_txd),
        .rgmii_txctl(rgmii_txctl),
        .rgmii_txc(rgmii_txc),
        .rgmii_rxd(rgmii_rxd),
        .rgmii_rxctl(rgmii_rxctl),
        .rgmii_rxc(rgmii_rxc),
        .gmii_txc(gmii_txc),
        .gmii_rxc(gmii_rxc),
        .gmii_rxdv(gmii_rxdv),
        .gmii_rxd(gmii_rxd),
        .gmii_txen(gmii_txen),
        .gmii_txd(gmii_txd)
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
        .udp_rx_len(udp_rx_len)
    );


    fifoc
    fifoc_dut(
        .rst(),

        .wr_clk(sys_clk),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),

        .rd_clk(sys_clk),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen),

        .full(fifoc_full)
    );

    fifod
    fifod_dut(
        .rst(),
        
        .wr_clk(sys_clk),
        .din(fifod_txd),
        .wr_en(fifod_txen),

        .rd_clk(gmii_txc),
        .dout(fifod_rxd),
        .rd_en(fifod_rxen),

        .full(fifod_full)
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
        .fifoc_txd(),
        .fifoc_txen(),
        .dev_rx_len(eth_rx_len)
    );

    wire [11:0] fw_data_len;



    fifo_write
    fifod_write_dut(
        .clk(sys_clk),
        .rst(),
        .err(),
        .fifo_txd(fifoc_txd),
        .fifo_txen(fifoc_txen),
        .fs(fs_fw),
        .fd(fd_fw),
        .data_cmd(fw_cmd),
        .so_data_len(fw_data_len)
    );

    fifoc2cs 
    fifoc2cs_dut (
        .led_cont(led_cont),
        .clk(sys_clk),
        .rst(),
        .err(),
        .fs(fs_fifoc2cs),
        .fd(fd_fifoc2cs),
        .fifoc_rxen(fifoc_rxen),
        .data_len(fw_data_len),
        .fifoc_rxd(fifoc_rxd),

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


    led
    led_dut(
        .clk(sys_clk),
        .rst(),
        .num(num),
        .lec(),
        .led(led),
        .fsu(fsu),
        .fsd(fsd),
        .fdu(fdu),
        .fdd(fdd),

        .reg00(LED_NUM),
        .reg01(fw_cmd),
        .reg02(kind_dev),
        .reg03(info_sr),
        .reg04(8'h6B),
        .reg05(cmd_filt),
        .reg06(cmd_mix0),
        .reg07(cmd_mix1),
        .reg08(cmd_reg4),
        .reg09(cmd_reg5),
        .reg0A(cmd_reg6),
        .reg0B(cmd_reg7)
    );

    key 
    key_dutu(
        .clk(sys_clk),
        .key(key[1]),
        .fs(fsu),
        .fd(fdu)
    );

    key 
    key_dutd(
        .clk(sys_clk),
        .key(key[0]),
        .fs(fsd),
        .fd(fdd)
    );

endmodule