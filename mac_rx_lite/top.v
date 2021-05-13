module top
(
    // CLK SECTION
    input sys_clk,
    input rgmii_rxc,
    output rgmii_txc,

    // RST
    input rst_n,

    // LED_SECTION
    output lec,
    output [3:0] led,

// ETH SECTION
    output e_mdc,
    inout e_mdio,
    output rgmii_txctl,
    output[3:0] rgmii_txd,
    input rgmii_rxctl,
    input [3:0] rgmii_rxd

    // ADC
    // TEST
    // input fs_adc_ext,
    // input [2:0] dev_num_ext
);


////// PARAMETER SECTIOM //////

// ETHERNET 
    parameter SOURCE_MAC_ADDR = 48'h00_0A_35_01_FE_C0;
    parameter SOURCE_IP_ADDR = 32'hC0_A8_00_02;
    parameter SOURCE_PORT = 16'd8080;
    parameter DESTINATION_IP_ADDR = 32'hC0_A8_00_03;
    parameter DESTINATION_PORT = 16'd8080;
    parameter MAC_TTL = 8'h80;

////// WIRE SECTION //////
    wire rst;
    wire fs_adc_ext;
    wire [2:0] dev_num_ext;
    assign fs_adc_ext = 1'b1;
    assign dev_num_ext = 3'h2;
// DATA_LEN
    wire [11:0] act_rx_len;
    wire [11:0] act_tx_len;
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

    wire fs_adc_check;
    wire fd_adc_check;
    wire fs_adc_conf;
    wire fd_adc_conf;
    wire fs_adc_read;
    wire fd_adc_read;
    wire fs_adc_fifo;
    wire fd_adc_fifo;

// RESET
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

//  LVDS
    assign rst = ~rst_n;

    wire [10:0] data_test;
// ## IP SECTION
// #region
    // reg reg_fs_fifod2mac;
    // assign fs_fifod2mac = reg_fs_fifod2mac;

    // always @(posedge sys_clk or posedge rst) begin
    //     if(rst) reg_fs_fifod2mac <= 1'b0;
    //     else if(fd_mac2fifoc) reg_fs_fifod2mac <= 1'b1;
    //     else if(fd_fifod2mac) reg_fs_fifod2mac <= 1'b0;
    //     else reg_fs_fifod2mac <= reg_fs_fifod2mac;
    // end

    // reg reg_fs_mac2fifoc;
    // reg reg_fd_udp_rx;

    // assign fs_mac2fifoc = fs_udp_rx;
    // assign fd_udp_rx = fd_mac2fifoc;

    reg reg_fs_udp_tx;
    assign fs_udp_tx = reg_fs_udp_tx;
    assign rst_mac = rst;
    assign rst_fifoc = rst;
    assign rst_eth2mac = rst;
    assign rst_mac2fifoc = rst;
    assign rst_fifod2mac = rst;
    assign act_tx_len = act_rx_len;

    always @(posedge sys_clk or posedge rst) begin
        if(rst) reg_fs_udp_tx <= 1'b0;
        else if(fd_udp_rx) reg_fs_udp_tx <= 1'b1;
        else if(fd_udp_tx) reg_fs_udp_tx <= 1'b0;
        else reg_fs_udp_tx <= reg_fs_udp_tx;
    end


    // #region
    // always @(posedge sys_clk or posedge rst) begin
    //     if(rst) begin
    //         reg_fs_mac2fifoc <= 1'b0;
    //         reg_fd_udp_rx <= 1'b0;
    //     end
    //     else if(fs_udp_rx) begin
    //         reg_fs_mac2fifoc <= 1'b1;
    //         reg_fd_udp_rx <= 1'b0;
    //     end
    //     else if(fd_mac2fifoc) begin
    //         reg_fs_mac2fifoc <= 1'b0;
    //         reg_fd_udp_rx <= 1'b1;
    //     end
    //     else if(fs_udp_rx == 1'b0) begin
    //         reg_fs_mac2fifoc <= 1'b0;
    //         reg_fd_udp_rx <= 1'b0;
    //     end
    //     else begin
    //         reg_fs_mac2fifoc <= reg_fs_mac2fifoc;
    //         reg_fd_udp_rx <= reg_fd_udp_rx;
    //     end
    // end

    // assign fs_mac2fifoc = reg_fs_mac2fifoc;
    // assign fd_udp_rx = reg_fd_udp_rx;

    // assign fs_udp_tx = fs_fifod2mac;
    // assign fd_udp_tx = fd_fifod2mac;

    // reg [7:0] data_test;

    // always@(posedge sys_clk or posedge rst) begin
    //     if(rst) data_test <= 8'h00;
    //     else if(udp_rxd[7] == 1'b1) data_test <= udp_rxd;
    //     else data_test <= data_test;
    // end
    // #endregion

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
        .udp_tx_len(act_tx_len),
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
    fifoc_dut(
        .rst(rst_fifoc),
        .wr_clk(gmii_rxc),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),
        .rd_clk(gmii_txc),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen),
        .rd_data_count(data_test)
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


    mac2fifoc 
    mac2fifoc_dut(
        .clk(gmii_rxc),
        .rst(rst_mac2fifoc),
        .fs(fs_udp_rx),
        .fd(fd_udp_rx),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifoc_txd),
        .fifoc_txen(fifoc_txen),
        .dev_rx_len(act_rx_len)
    );

    fifod2mac 
    fifod2mac_dut (
        .clk(gmii_txc),
        .rst(rst),
        .fs(fs_udp_tx),
        .fd(fd_udp_tx),
        .data_len(act_rx_len),
        .fifod_rxen(fifoc_rxen),
        .fifod_rxd(fifoc_rxd),
        .udp_txen(udp_txen),
        .udp_txd(udp_txd),
        .flag_udp_tx_prep(flag_udp_tx_prep),
        .flag_udp_tx_req(flag_udp_tx_req)
    );

    led
    led_dut (
        .sys_clk(sys_clk),
        .rst(rst),
        .data(data_test[7:0]),
        .lec(lec),
        .led(led)
    );

endmodule

