module top(
    input sys_clk,
    input rgmii_rxc,
    output rgmii_txc,

    input [3:0] key,
    
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
    wire fs_fr, fd_fr;
    wire rst_mac, rst_fifoc, rst_eth2mac;
    wire rst_mac2fifoc, rst_fifoc2cs;

    wire [7:0] dev_info, dev_kind, dev_smpr;
    wire [7:0] cmd_kdev, cmd_smpr, cmd_filt;
    wire [7:0] cmd_mix0, cmd_mix1, cmd_reg4;
    wire [7:0] cmd_reg5, cmd_reg6, cmd_reg7;

    wire [7:0] adc_reg00, adc_reg01, adc_reg02;
    wire [7:0] adc_reg06, adc_reg07, adc_reg08;
    wire [7:0] adc_reg09, adc_reg10, adc_reg11;
    wire [7:0] adc_reg12, adc_reg13, adc_regap;

    wire [95:0] dat; 
    wire rst;

    wire [7:0] fifoc_txd, fifoc_rxd;
    wire fifoc_txen, fifoc_rxen;

    wire [3:0] mac2fifoc_so;

    reg [3:0] state;
    wire [3:0] keys;
    wire [31:0] leds;
    localparam IDLE = 4'h8, MCFC = 4'h9, UPRX = 4'hA, FIFR = 4'hB;
    localparam TEST = 4'h5;
    // assign led[31:16] = reg_led;
    // assign led[15] = ~fs_udp_rx;
    // assign led[14] = ~fd_udp_rx;
    // assign led[13] = ~fs_mac2fifoc;
    // assign led[12] = ~fd_mac2fifoc;
    // assign led[11:8] = ~eth_rx_len[3:0];
    // assign led[7:4] = ~mac2fifoc_so;
    // assign led[3:0] = ~4'hA;
    assign fs_mac2fifoc = (state == MCFC);
    assign fd_udp_rx = (state == UPRX);
    assign fs_fr = (state == FIFR);
    assign rst = ~key[3];
    assign leds[19:16] = keys;
    assign lec = ~state;
    assign led = ~leds;
    assign leds[7:0] = eth_rx_len[7:0];
    assign leds[21] = fs_udp_rx;
    assign leds[20] = fd_udp_rx;
    

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
                    if(fs_udp_rx == 1'b0) state <= IDLE;
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
        .udp_rx_len(udp_rx_len),
        .so(leds[15:12])
    );

    fifod
    fifoc_dut(
        .rst(rst),

        .wr_clk(gmii_rxc),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),

        .rd_clk(sys_clk),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen),
        .rd_data_count(leds[31:22]),
        .wr_data_count()
    );

    mac2fifoc 
    mac2fifoc_dut(
        .clk(gmii_rxc),
        .rst(rst),
        .fs(fs_mac2fifoc),
        .fd(fd_mac2fifoc),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifoc_txd),
        .fifoc_txen(fifoc_txen),
        .dev_rx_len(eth_rx_len),
        .so(leds[11:8])
    );

    fifo_read
    fifo_read_dut(
        .clk(sys_clk),
        .rst(rst),
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
// # region
    // led
    // led_dut(
    //     .clk(sys_clk),
    //     .rst(rst),
    //     .num(num),
    //     .lec(),
    //     .led(led),
    //     .fsu(fsu),
    //     .fsd(fsd),
    //     .fdu(fdu),
    //     .fdd(fdd),

    //     .reg00(dat[95:88]),
    //     .reg01(dat[87:80]),
    //     .reg02(dat[79:72]),
    //     .reg03(dat[71:64]),
    //     .reg04(dat[63:56]),
    //     .reg05(dat[55:48]),
    //     .reg06(dat[47:40]),
    //     .reg07(dat[39:32]),
    //     .reg08(dat[31:24]),
    //     .reg09(dat[23:16]),
    //     .reg0A(dat[15:8]),
    //     .reg0B(dat[7:0])
    // );

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