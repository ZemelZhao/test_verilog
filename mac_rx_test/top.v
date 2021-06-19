module top(
    input sys_clk,
    input rgmii_rxc,
    input rgmii_txc,

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

    wire [3:0] num;
    wire fsu, fdu, fsd, fdd;

    wire [7:0] reg00, reg01, reg02, reg03;
    wire [7:0] reg04, reg05, reg06, reg07;
    wire [7:0] reg08, reg09, reg0A, reg0B;
    wire [7:0] reg0C, reg0D, reg0E, reg0F;

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

    wire fs_udp_rx, fd_udp_rx;
    wire fs_udp_tx, fd_udp_tx;
    wire fs_mac2fifoc, fs_fifoc2cs;
    wire fd_mac2fifoc, fd_fifoc2cs;
    wire rst_mac, rst_fifoc, rst_eth2mac;
    wire rst_mac2fifoc, rst_fifoc2cs;

    wire [7:0] dev_info, dev_kind, dev_smpr;
    wire [7:0] cmd_kdev, cmd_smpr, cmd_filt;
    wire [7:0] cmd_mix0, cmd_mix1, cmd_reg4;
    wire [7:0] cmd_reg5, cmd_reg6, cmd_reg7;

    wire [7:0] adc_reg00, adc_reg01, adc_reg02;
    wire [7:0] adc_reg03, adc_reg04, adc_reg05;
    wire [7:0] adc_reg06, adc_reg07, adc_reg08;
    wire [7:0] adc_reg09, adc_reg10, adc_reg11;
    wire [7:0] adc_reg12, adc_reg13, adc_regap;

    wire [7:0] fifoc_txd, fifoc_rxd;
    wire fifoc_txen, fifoc_rxen;
    wire fifoc_full, fifod_full, fifoa_full;
    wire fifoc_empty, fifod_empty, fifoa_empty;

// CS 
// #region
    // cs 
    // cs_dut(
    //     .clk(sys_clk),
    //     .rst(~rst_n),
    //     .spi_mc(),
    //     .fs_adc_ext(),
    //     .dev_num_ext(),
    //     .dev_info(dev_info),
    //     .dev_kind(dev_kind),
    //     .dev_smpr(dev_smpr),
    //     .eth_rx_len(eth_rx_len),
    //     .eth_tx_len(eth_tx_len),
    //     .adc_rx_len(adc_rx_len),
    //     .cmd_kdev(cmd_kdev),
    //     .cmd_smpr(cmd_smpr),
    //     .cmd_filt(cmd_filt),
    //     .cmd_mix0(cmd_mix0),
    //     .cmd_mix1(cmd_mix1),
    //     .cmd_reg4(cmd_reg4),
    //     .cmd_reg5(cmd_reg5),
    //     .cmd_reg6(cmd_reg6),
    //     .cmd_reg7(cmd_reg7),
    //     .adc_reg00(adc_reg00),
    //     .adc_reg01(adc_reg01),
    //     .adc_reg02(adc_reg02),
    //     .adc_reg03(adc_reg03),
    //     .adc_reg04(adc_reg04),
    //     .adc_reg05(adc_reg05),
    //     .adc_reg06(adc_reg06),
    //     .adc_reg07(adc_reg07),
    //     .adc_reg08(adc_reg08),
    //     .adc_reg09(adc_reg09),
    //     .adc_reg10(adc_reg10),
    //     .adc_reg11(adc_reg11),
    //     .adc_reg12(adc_reg12),
    //     .adc_reg13(adc_reg13),
    //     .adc_regap(adc_regap),
    //     .fs_udp_rx(fs_udp_rx),
    //     .fs_udp_tx(fs_udp_tx),
    //     .fs_fifod2mac(),
    //     .fs_mac2fifoc(fs_mac2fifoc),
    //     .fs_fifoc2cs(fs_fifoc2cs),
    //     .fs_adc_check(),
    //     .fs_adc_conf(),
    //     .fs_adc_read(),
    //     .fs_adc_fifo(),
    //     .fd_udp_rx(fd_udp_rx),
    //     .fd_udp_tx(fd_udp_tx),
    //     .fd_fifod2mac(),
    //     .fd_mac2fifoc(fd_mac2fifoc),
    //     .fd_fifoc2cs(fd_fifoc2cs),
    //     .fd_adc_check(),
    //     .fd_adc_conf(),
    //     .fd_adc_read(),
    //     .fd_adc_fifo(),
    //     .rst_mac(rst_mac),
    //     .rst_adc(),
    //     .rst_fifod(),
    //     .rst_fifoc(rst_fifoc),
    //     .rst_eth2mac(rst_eth2mac),
    //     .rst_fifod2mac(),
    //     .rst_mac2fifoc(rst_mac2fifoc),
    //     .rst_adc2fifod(),
    //     .rst_fifoc2cs(rst_fifoc2cs)
    // );

    // fifoc2cs 
    // fifoc2cs_dut(
    //     .clk(clk),
    //     .rst(rst_fifoc2cs),
    //     .err(),
    //     .fs(fs_fifoc2cs),
    //     .fd(fd_fifoc2cs),
    //     .fifoc_rxen(fifoc_rxen),
    //     .fifoc_rxd(fifoc_rxd),
    //     .kind_dev(cmd_kdev),
    //     .info_sr(cmd_smpr),
    //     .cmd_filt(cmd_filt),
    //     .cmd_mix0(cmd_mix0),
    //     .cmd_mix1(cmd_mix1),
    //     .cmd_reg4(cmd_reg4),
    //     .cmd_reg5(cmd_reg5),
    //     .cmd_reg6(cmd_reg6),
    //     .cmd_reg7(cmd_reg7)
    // );


// #endregion

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
        .udp_rx_len(eth_rx_len)
    );

    fifod
    fifoc_dut(
        .rst(~rst_n),

        .wr_clk(gmii_rxc),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),

        .rd_clk(sys_clk),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen)
    );

    mac2fifoc 
    mac2fifoc_dut(
        .clk(gmii_rxc),
        .rst(~rst_n),
        .fs(fs_mac2fifoc),
        .fd(fd_mac2fifoc),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifoc_txd),
        .fifoc_txen(fifoc_txen),
        .dev_rx_len(eth_rx_len)
    );

// #endregion

// LED
// # region
    led
    led_dut(
        .clk(sys_clk),
        .rst(~rst_n),
        .num(num),
        .lec(lec),
        .led(led),
        .fsu(fsu),
        .fsd(fsd),
        .fdu(fdu),
        .fdd(fdd),

        .reg00(reg00),
        .reg01(reg01),
        .reg02(reg02),
        .reg03(reg03),
        .reg04(reg04),
        .reg05(reg05),
        .reg06(reg06),
        .reg07(reg07),
        .reg08(reg08),
        .reg09(reg09),
        .reg0A(reg0A),
        .reg0B(reg0B),
        .reg0C(reg0C),
        .reg0D(reg0D),
        .reg0E(reg0E),
        .reg0F(reg0F)
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