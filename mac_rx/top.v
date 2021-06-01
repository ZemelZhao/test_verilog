module top(
    input sysc,
    input rgmii_txc,
    input rgmii_rxc,

    input rst_n,

    input key[1:0],
    output [3:0] lec,
    output [31:0] led,

    output e_mdc,
    input e_mdio,
    input rgmii_rxctl,
    output rgmii_txctl,
    input [3:0] rgmii_rxd,
    output [3:0] rgmii_txd

);

// ETH
    wire gmii_rxc, gmii_txc;
    wire gmii_rxdv, gmii_txen;
    wire [7:0] gmii_rxd, gmii_txd;

// MAC
    parameter SOURCE_MAC_ADDR = 48'h00_0A_35_01_FE_C0;
    parameter SOURCE_IP_ADDR = 32'hC0_A8_00_02;
    parameter SOURCE_PORT = 16'h1F90;
    parameter DESTINATION_IP_ADDR = 32'hC0_A8_00_03;
    parameter DESTINATION_PORT = 16'h1F90;
    parameter MAC_TTL = 8'h80;
    wire mac_rxdv, mac_txdv;
    wire [7:0] mac_rxd, mac_txd;
    wire fs_udp_rx, fs_udp_tx;
    wire fd_udp_rx, fd_udp_tx;
    wire [7:0] udp_rxd, udp_txd;
    wire flag_udp_tx_req, flag_udp_tx_prep;
    wire [11:0] dat_tx_len;
    wire [15:0] udp_rx_len, dat_rx_len;
    wire udp_txen;
    wire [10:0] udp_rx_addr;

// FIFO
    wire fifo_rxc, fifo_txc;
    wire fifo_rxen, fifo_txen;
    wire [7:0] fifo_rxd, fifo_txd;
    wire fifo_empty, fifo_full;

// LED
    wire ledc;
    wire [3:0] led_num;
    wire led_fsu, led_fsd;
    wire led_fdu, led_fdd;

// DATA
    wire [95:0] data;
    wire rst;
    wire fs_mac2fifoc, fd_mac2fifoc;
    
    assign rst = ~rst_n;
    assign fifo_rxc = sysc;
    assign fifo_txc = gmii_rxc;
    assign ledc = sysc;
    assign led_num = 4'h2;

    reg [3:0] state, next_state;
    localparam IDLE = 4'h0, UPRX = 4'h1;


    always@(posedge sysc or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    assign fs_mac2fifoc = fs_udp_rx;
    assign fd_udp_rx = fd_mac2fifoc;


// #region
    eth 
    eth_dut (
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
    mac_dut (
        .gmii_txc(gmii_txc),
        .gmii_rxc(gmii_rxc),
        .rst(rst),
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
        .udp_tx_len(),
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
        .rst(rst),
        .wr_clk(fifo_txc),
        .wr_en(fifo_txen),
        .din(fifo_txd),
        .full(fifo_full),
        .rd_clk(fifo_rxc),
        .rd_en(fifo_rxen),
        .dout(fifo_rxd),
        .empty(fifo_empty)
    );

    led 
    led_dut (
        .clk(ledc),
        .rst(rst),
        .num(led_num),
        .lec(lec),
        .led(led),
        .fsu(led_fsu),
        .fsd(led_fsd),
        .fdu(led_fdu),
        .fdd(led_fdd),
        .reg00(data[95:88]),
        .reg01(data[87:80]),
        .reg02(data[79:72]),
        .reg03(data[71:64]),
        .reg04(data[63:56]),
        .reg05(data[55:48]),
        .reg06(data[47:40]),
        .reg07(data[39:32]),
        .reg08(data[31:24]),
        .reg09(data[23:16]),
        .reg0A(data[15:8]),
        .reg0B(data[7:0])
    );


    key 
    key_dutu (
        .clk(sysc),
        .key(key[1]),
        .fs(led_fsu),
        .fd(led_fdu)
    );

    key 
    key_dutd(
        .clk(sysc),
        .key(key[0]),
        .fs(led_fsd),
        .fd(led_fdd)
    );    

    eth2mac 
    eth2mac_dut (
        .rst(rst),
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
    mac2fifoc_dut (
        .clk(gmii_rxc),
        .rst(rst),
        .fs(fs_mac2fifoc),
        .fd(fd_mac2fifoc),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifo_txd),
        .fifoc_txen(fifo_txen),
        .dev_rx_len(dat_rx_len)
    );
// #endregion

endmodule