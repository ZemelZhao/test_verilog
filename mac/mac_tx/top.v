module top
(
    // CLK SECTION
    input sys_clk,
    input rgmii_rxc,
    output rgmii_txc,

    // RST
    input rstn,

    // LED_SECTION
    output [3:0] led,

    // ETH SECTION
    output e_mdc,
    inout e_mdio,
    output rgmii_txctl,
    output[3:0] rgmii_txd,
    input rgmii_rxctl,
    input [3:0] rgmii_rxd
);


////// PARAMETER SECTIOM //////

// ETHERNET 
    parameter SOURCE_MAC_ADDR = 48'h00_0A_35_01_FE_C0;
    parameter SOURCE_IP_ADDR = 32'hC0_A8_00_02;
    parameter SOURCE_PORT = 16'h1F90;
    parameter DESTINATION_IP_ADDR = 32'hC0_A8_00_03;
    parameter DESTINATION_PORT = 16'h1F90;
    parameter MAC_TTL = 8'h80;

////// WIRE SECTION //////
// DATA_LEN
    wire [11:0] eth_rx_len;
    wire [11:0] eth_tx_len;
    wire [9:0] adc_rx_len;

// CMD
    wire [7:0] cmd_kdev;
    wire [7:0] cmd_smpr;
    wire [7:0] cmd_filt;
    wire [7:0] cmd_mix0;
    wire [7:0] cmd_mix1;
    wire [7:0] cmd_reg4;
    wire [7:0] cmd_reg5;
    wire [7:0] cmd_reg6;
    wire [7:0] cmd_reg7;

// MAC
    wire mac_rxdv;
    wire mac_txdv;
    wire [7:0] mac_rxd;
    wire [7:0] mac_txd;

    wire [15:0] udp_rx_len;
    wire [10:0] udp_rx_addr;
    wire udp_txen;
    wire [7:0] udp_txd;
    wire [7:0] udp_rxd;

    wire flag_udp_tx_req;
    wire flag_udp_tx_prep;

// ETH
    wire gmii_rxc;
    wire gmii_txc;
    wire gmii_rxdv;
    wire gmii_txen;
    wire [7:0] gmii_rxd;
    wire [7:0] gmii_txd;

// ADC
    wire spi_mc; // CLK
    wire fifod_txens;

    wire [7:0] adc_rxd;

    wire [7:0] dev_smpr;
    wire [7:0] cache_dev_info;
    wire [7:0] cache_dev_kind;

    wire [7:0] adc_reg00;
    wire [7:0] adc_reg01;
    wire [7:0] adc_reg02;
    wire [7:0] adc_reg03;
    wire [7:0] adc_reg04;
    wire [7:0] adc_reg05;
    wire [7:0] adc_reg06;
    wire [7:0] adc_reg07;
    wire [7:0] adc_reg08;
    wire [7:0] adc_reg09;
    wire [7:0] adc_reg10;
    wire [7:0] adc_reg11;
    wire [7:0] adc_reg12;
    wire [7:0] adc_reg13;
    wire [7:0] adc_regap;

    wire [3:0] cache_cs;
    wire [3:0] cache_miso;
    wire [3:0] cache_mosi;
    wire [3:0] cache_sclk;

// FIFO
    wire fifod_rxen;
    wire fifod_txen;
    wire [7:0] fifod_rxd;
    wire [7:0] fifod_txd;

    wire fifoc_rxen;
    wire fifoc_txen;
    wire [7:0] fifoc_rxd;
    wire [7:0] fifoc_txd;   

    wire [7:0] din;

// FLAG
    wire fs_udp_tx;
    wire fd_udp_tx;
    wire fs_udp_rx;
    wire fd_udp_rx;

    wire fs_fifod2mac;
    wire fd_fifod2mac;
    wire fs_mac2fifoc;
    wire fd_mac2fifoc;
    wire fs_fifoc2cs;
    wire fd_fifoc2cs;

    wire fs_fifowrite;
    wire fd_fifowrite;

    wire fs_adc_check;
    wire fd_adc_check;
    wire fs_adc_conf;
    wire fd_adc_conf;
    wire fs_adc_read;
    wire fd_adc_read;
    wire fs_adc_fifo;
    wire fd_adc_fifo;

// RESET
    wire rst;
    wire rst_mac;
    wire rst_adc;
    wire rst_fifod;
    wire rst_fifoc;
    wire rst_eth2mac;
    wire rst_fifod2mac;
    wire rst_mac2fifoc;
    wire rst_adc2fifod;
    wire rst_fifoc2cs;
    
// ERROR
    wire err_fifoc2cs;

// ## IP SECTION
// #region
    assign rst = ~rstn;

// #### 1. NODE SECTION
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



    fifod
    fifod_dut(
        .rst(rst),
        .wr_clk(sys_clk),
        .din(fifod_txd),
        .wr_en(fifod_txen),
        .rd_clk(gmii_txc),
        .dout(fifod_rxd),
        .rd_en(fifod_rxen)
    );

    fifo_write 
    fifo_write_dut (
        .clk(fifod_txd),
        .rst(rst),
        .err(),
        .din(din),
        .dout(fifod_txd),
        .fifo_txen(fifod_txen),
        .fs(fs_fifowrite),
        .fd(fd_fifowrite),
        .data_len(eth_tx_len)
    );

    cs 
    cs_dut (
        .sys_clk(sys_clk),
        .fs_fifowrite(fs_fifowrite),
        .fd_fifowrite(fd_fifowrite),
        .fs_fifod2mac(fs_fifod2mac),
        .fd_fifod2mac(fd_fifod2mac),
        .rst(rst),
        .din(din)
    );


// #### 2. MODE SECTION
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

    fifod2mac 
    fifod2mac_dut(
        .clk(gmii_txc),
        .rst(rst_fifod2mac),
        .fs(fs_fifod2mac),
        .fd(fd_fifod2mac),
        .data_len(eth_tx_len),
        .fifod_rxen(fifod_rxen),
        .fifod_rxd(fifod_rxd),
        .flag_udp_tx_prep(flag_udp_tx_prep),
        .flag_udp_tx_req(flag_udp_tx_req),
        .udp_txen(udp_txen),
        .udp_txd(udp_txd)
    );


endmodule

