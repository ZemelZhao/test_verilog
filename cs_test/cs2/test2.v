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
    localparam LED_NUM = 8'h65;
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


// COMMAND SECTION
// #region

    wire [7:0] kind_dev;
    wire [7:0] info_sr;
    wire [7:0] cmd_filt;
    wire [7:0] cmd_mix0;
    wire [7:0] cmd_mix1;
    wire [7:0] cmd_reg4;
    wire [7:0] cmd_reg5;
    wire [7:0] cmd_reg6;
    wire [7:0] cmd_reg7;

    wire [7:0] adc_reg00, adc_reg01, adc_reg02, adc_reg03;
    wire [7:0] adc_reg04, adc_reg05, adc_reg06, adc_reg07;
    wire [7:0] adc_reg08, adc_reg09, adc_reg10, adc_reg11;
    wire [7:0] adc_reg12, adc_reg13, adc_regap;

// #endregion

// OTHER SECTION

    wire fs_udp_rx, fd_udp_rx;
    wire fs_mac2fifoc, fd_mac2fifoc;
    wire fs_fifoc2cs, fd_fifoc2cs;

    wire fs_udp_tx, fd_udp_tx;
    wire fs_fifod2mac, fd_fifod2mac;

    wire fs_adc_check, fd_adc_check;
    wire fs_adc_conf, fd_adc_conf;
    wire fs_adc_read, fd_adc_read;
    wire fs_adc_fifo, fd_adc_fifo;

    wire fifoa_full, fifoc_full, fifod_full;

    wire rst_fifoc, rst_fifod;
    wire rst_mac, rst_adc;
    wire rst_eth2mac, rst_fifod2mac, rst_mac2fifoc;
    wire rst_adc2fifod, rst_fifoc2cs;
    wire rst;


    wire [7:0] fifoc_txd, fifoc_rxd;
    wire [7:0] fifod_txd, fifod_rxd;
    wire fifoc_txen, fifoc_rxen;
    wire fifod_txen, fifod_rxen;

    wire fsu, fdu, fsd, fdd;
    wire [3:0] num;

    assign rst = ~rst_n;
    assign num = 4'h2;


// #endregion

    reg [3:0] state;
    wire fs_send, fs_recv;
    localparam IDLE = 4'hC, MCFC = 4'h9, UPRX = 4'hA, FIFR = 4'hB;
    localparam TEST = 4'h3, HAHA = 4'hF;

    // assign fs_mac2fifoc = (state == MCFC);
    // assign fd_udp_rx = (state == UPRX);
    // assign fs_fifoc2cs = (state == FIFR);
    assign fs_recv = (state == HAHA);
    assign rst = ~rst_n;
    assign num = 4'h2;

    assign fifod_txen = 1'b0;
    assign fifod_rxen = 1'b0;
    assign fifod_txd = 8'h0;
    assign fifoa_full = 1'b0;

    assign lec = ~led_cont;



// #endregion
    // always@(posedge sys_clk or posedge rst) begin
    //     if(rst) state <= IDLE;
    //     else begin
    //         case(state)
    //             IDLE: begin
    //                 if(fs_send) state <= HAHA;
    //                 else state <= IDLE;
    //             end
    //             HAHA: begin
    //                 if(fs_send == 1'b0) state <= IDLE;
    //                 else state <= HAHA;
    //             end
    //             TEST: begin
    //                 if(fs_udp_rx) begin
    //                     state <= MCFC;
    //                 end
    //                 else state <= TEST;
    //             end
    //             MCFC: begin
    //                 if(fd_mac2fifoc) state <= UPRX;
    //                 else state <= MCFC;
    //             end
    //             UPRX: begin
    //                 if(fs_udp_rx == 1'b0) state <= FIFR;
    //                 else state <= UPRX;
    //             end
    //             FIFR: begin
    //                 if(fd_fifoc2cs) state <= IDLE;
    //                 else state <= FIFR;
    //             end
    //             default: state <= IDLE;
    //         endcase
    //     end
    // end

// TEST
// #region
    wire [3:0] led_cont;
    wire err_fifoc2cs;
    // assign led = ~led_cont;
    assign fifoa_full = 1'b0;
    assign fifod_txd = 8'h0;
    assign fifod_txen = 1'h0;
    assign fifod_rxen = 1'b0;



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
        .rst(rst_fifoc),

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
        .rst(rst_fifod),
        
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
        .fs(fs_mac2fifoc),
        .fd(fd_mac2fifoc),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifoc_txd),
        .fifoc_txen(fifoc_txen),
        .dev_rx_len(eth_rx_len)
    );

    fifoc2cs 
    fifoc2cs_dut (
        .clk(sys_clk),
        .rst(rst),
        .err(err_fifoc2cs),
        .fs(fs_fifoc2cs),
        .fd(fd_fifoc2cs),
        .check_show(led[31:24]),
        .fifoc_rxen(fifoc_rxen),
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

    // fifod2mac 
    // fifod2mac_dut (
    //     .clk(sys_clk),
    //     .rst(rst),
    //     .fs(fs_fifod2mac),
    //     .fd(fd_fifod2mac),
    //     .data_len(eth_tx_len),
    //     .fifod_rxen(fifod_rxen),
    //     .fifod_rxd(fifod_rxd),
    //     .udp_txen(udp_txen),
    //     .udp_txd(udp_txd),
    //     .flag_udp_tx_prep(flag_udp_tx_prep),
    //     .flag_udp_tx_req(flag_udp_tx_req)
    // );

// #endregion

// CONSOLE
// #region
    cs
    cs_dut(
        .clk(sys_clk),
        .rst(rst),

        .fs_udp_rx(fs_udp_rx),
        .fs_mac2fifoc(fs_mac2fifoc),
        .fs_fifoc2cs(fs_fifoc2cs),
        .fd_udp_rx(fd_udp_rx),
        .fd_mac2fifoc(fd_mac2fifoc),
        .fd_fifoc2cs(fd_fifoc2cs),

        .led_cont(led_cont),

        .fifoa_full(fifoa_full),
        .fifoc_full(fifoc_full),
        .fifod_full(fifod_full),
        .fs_send(fs_send),
        .fs_recv(fs_recv)

        // .led_cont(led_cont)
    );

// #endregion

// LED
// #region
    led
    led_dut(
        .clk(sys_clk),
        .rst(rst),
        .num(num),
        .lec(),
        .led(),
        .fsu(fsu),
        .fsd(fsd),
        .fdu(fdu),
        .fdd(fdd),

        .reg00(LED_NUM),
        .reg01(8'hAA),
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
// #endregion

endmodule