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
    localparam LED_NUM = 8'h78;
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






endmodule