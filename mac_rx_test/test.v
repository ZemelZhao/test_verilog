module top(
    input sys_clk,

    input rgmii_rxc,
    output rgmii_txc,

    input rst_n,
    input [1:0] key,
    output [3:0] lec,
    output [31:0] led,

    output e_mdc,
    input e_mdio,
    output rgmii_txctl,
    output [3:0] rgmii_txd,
    input rgmii_rxctl,
    input [3:0] rgmii_rxd
);

// MAC SECTION
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
// #endregion


// OTHER SECTION
// #region
    wire fs_udp_rx, fd_udp_rx;
    wire fs_udp_tx, fd_udp_tx;
    wire fs_mac2fifoc, fs_fifoc2cs;
    wire fd_mac2fifoc, fd_fifoc2cs;
    wire fs_fr, fd_fr;
    wire rst_mac, rst_fifoc, rst_eth2mac;
    wire rst_mac2fifoc, rst_fifoc2cs, rst;

    wire [95:0] dat;
    wire [7:0] fifoc_txd, fifoc_rxd;
    wire fifoc_txen, fifoc_rxen;

    wire fsu, fdu, fsd, fdd;
    wire [3:0] num;

    reg [3:0] state;
    localparam IDLE = 4'h8, MCFC = 4'h9, UPRX = 4'hA, FIFR = 4'hB;

    assign fs_mac2fifoc = (state == MCFC);
    assign fd_udp_rx = (state == UPRX);
    assign fs_fr = (state == FIFR);
    assign rst = ~rst_n;
    assign num = 4'h2;


// #endregion
    always@(posedge sys_clk or posedge rst) begin
        if(rst) state <= IDLE;
        else begin
            case(state)
                IDLE: begin
                    if(fs_udp_rx) begin
                        state <= MCFC;
                    end
                    else state <= IDLE;
                end
                MCFC: begin
                    if(fd_mac2fifoc) state <= UPRX;
                    else state <= MCFC;
                end
                UPRX: begin
                    if(fs_udp_rx == 1'b0) state <= FIFR;
                    else state <= UPRX;
                end
                FIFR: begin
                    if(fd_fr) state <= IDLE;
                    else state <= FIFR;
                end
                default: state <= IDLE;
            endcase
        end
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
        .rst(rst_eth2mac),
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
        .rst(rst_mac),
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

    fifod
    fifoc_dut(
        .rst(rst_fifoc),

        .wr_clk(gmii_rxc),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),

        .rd_clk(sys_clk),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen),
        .rd_data_count(),
        .wr_data_count()
    );

    mac2fifoc 
    mac2fifoc_dut(
        .clk(gmii_rxc),
        .rst(rst_mac2fifoc),
        .fs(fs_mac2fifoc),
        .fd(fd_mac2fifoc),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifoc_txd),
        .fifoc_txen(fifoc_txen),
        .dev_rx_len(eth_rx_len)
    );

    fifo_read
    fifo_read_dut(
        .clk(sys_clk),
        .rst(rst_fifoc),
        .err(),
        .FIFO_NUM(eth_rx_len),
        .fifo_rxd(fifoc_rxd),
        .fifo_rxen(fifoc_rxen),
        .res(dat),
        .fs(fs_fr),
        .fd(fd_fr)
    );

// #endregion


// LED
// #region
    led
    led_dut(
        .clk(sys_clk),
        .rst(rst),
        .num(num),
        .lec(lec),
        .led(led),
        .fsu(fsu),
        .fsd(fsd),
        .fdu(fdu),
        .fdd(fdd),

        .reg00(dat[95:88]),
        .reg01(dat[87:80]),
        .reg02(dat[79:72]),
        .reg03(dat[71:64]),
        .reg04(dat[63:56]),
        .reg05(dat[55:48]),
        .reg06(dat[47:40]),
        .reg07(dat[39:32]),
        .reg08(dat[31:24]),
        .reg09(dat[23:16]),
        .reg0A(dat[15:8]),
        .reg0B(dat[7:0])
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
// #endregion


endmodule