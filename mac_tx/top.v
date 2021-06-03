module top(
    input sysc,
    input rgmii_rxc,
    output rgmii_txc,

    input rst_n,

    input key,
    output e_mdc,
    input e_mdio,
    input rgmii_rxctl,
    output rgmii_txctl,
    input [3:0] rgmii_rxd,
    output [3:0] rgmii_txd,
    output [3:0] led
);

    wire gmii_rxc, gmii_txc;
    wire gmii_rxdv, gmii_txen;
    wire [7:0] gmii_rxd, gmii_txd;

// MAC
    parameter SOURCE_MAC_ADDR = 48'h00_0A_35_01_FE_C0;
    parameter SOURCE_IP_ADDR = 32'hC0_A8_00_02;
    parameter SOURCE_PORT = 32'd8080;
    parameter DESTINATION_IP_ADDR = 32'hC0_A8_00_03;
    parameter DESTINATION_PORT = 32'd8080;
    parameter MAC_TTL = 8'h80;
    wire mac_rxdv, mac_txdv;
    wire [7:0] mac_rxd, mac_txd;
    wire fs_udp_rx;
    reg fs_udp_tx;
    wire fd_udp_rx, fd_udp_tx;
    wire [7:0] udp_rxd, udp_txd;
    wire flag_udp_tx_req, flag_udp_tx_prep;
    wire [11:0] dat_tx_len, dat_rx_len;
    wire [15:0] udp_rx_len;
    wire udp_txen;
    wire [10:0] udp_rx_addr;

// FIFO
    wire fifo_rxc, fifo_txc;
    wire fifo_rxen, fifo_txen;
    wire [7:0] fifo_rxd, fifo_txd;
    wire fifo_empty, fifo_full;

    wire rst;
    wire fs_key, fd_key;
    reg [3:0] reg_led;

    assign rst = ~rst_n;
    assign dat_tx_len = 12'hC;
    assign led[0] = fifo_full;
    assign led[3:1] = reg_led;

    always@(posedge sysc or posedge rst) begin
        if(rst) begin
            reg_led[3:1] <= 3'h2;
            fs_udp_tx <= 1'b0;
        end
        else if(fd_key) fs_udp_tx <= 1'b1;
        else if(fd_udp_tx) fs_udp_tx <= 1'b0;
        else fs_udp_tx <= fs_udp_tx;
    end

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
        .udp_tx_len(dat_tx_len),
        .flag_udp_tx_req(flag_udp_tx_req),
        .udp_txen(udp_txen),
        .flag_udp_tx_prep(flag_udp_tx_prep),
        .udp_txd(8'h5A),
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

    fifod2mac 
    fifod2mac_dut(
        .clk(gmii_txc),
        .rst(rst),
        .fs(fs_udp_tx),
        .fd(fd_udp_tx),
        .data_len(dat_tx_len),
        .fifod_rxen(fifo_rxen),
        .fifod_rxd(fifo_rxd),
        .udp_txen(udp_txen),
        .udp_txd(udp_txd),
        .flag_udp_tx_prep(flag_udp_tx_prep),
        .flag_udp_tx_req(flag_udp_tx_req)
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

    fifo_write 
    fifo_write_dut (
        .clk(sysc),
        .rst(rst),
        .err(),
        .fifo_txd(fifo_txd),
        .fifo_txen(fifo_txen),
        .fs(fs_key),
        .fd(fd_key),
        .data_len(dat_tx_len)
    );


    key
    key_dut(
        .clk(sysc),
        .key(key),
        .fs(fs_key),
        .fd(fd_key)
    );


endmodule