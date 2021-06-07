module top(
    input sysc,
    input rgmii_rxc,
    output rgmii_txc,

    input[3:0] key,
    output e_mdc,
    input e_mdio,
    input rgmii_rxctl,
    output rgmii_txctl,
    input [3:0] rgmii_rxd,
    output [3:0] rgmii_txd,
    output [3:0] lec
    // output [31:0] led
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
    wire fs_udp_tx;
    wire fd_udp_rx, fd_udp_tx;
    wire [7:0] udp_rxd, udp_txd;
    wire flag_udp_tx_req, flag_udp_tx_prep;
    wire [11:0] dat_tx_len, dat_rx_len;
    wire [15:0] udp_rx_len;
    wire udp_txen;
    wire [10:0] udp_rx_addr;

// FIFO
    // wire [11:0] dat_tx_len;
    wire fifo_rxen, fifo_txen;
    wire [7:0] fifo_rxd, fifo_txd;
    wire fifo_empty, fifo_full;

    wire rst;
    wire fs_key; 
    wire fd_key;
    // reg [3:0] reg_led;
    reg [3:0] state;
    localparam IDLE = 4'h1, WAIT = 4'h2, UPTX = 4'h3, LAST = 4'h4;
    // localparam IDLE = 3'h0, FIWR = 3'h1, WAIT = 3'h2, FIRD = 3'h3;
    // localparam LAST = 3'h4, LAT0 = 3'h5, LAT1 = 3'h6;
    // wire fs_fw, fs_fr, fd_fw, fd_fr;
    wire [95:0] data;
    assign fs_udp_tx = (state == UPTX);

    assign rst = ~key[3];
    assign dat_tx_len = 12'hC;

    always@(posedge sysc or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state) 
                IDLE: begin
                    if(fifo_full == 1'b0)state <= WAIT;
                    else state <= IDLE;
                end
                WAIT: begin
                    if(fd_key) state <= UPTX;
                    else state <= WAIT;
                end
                UPTX: begin
                    if(fd_udp_tx) state <= LAST;
                    else state <= UPTX;
                end
                LAST: begin
                    state <= IDLE;
                end
            endcase
        end
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
        .wr_clk(sysc),
        .wr_en(fifo_txen),
        .din(fifo_txd),
        .full(fifo_full),
        .rd_clk(gmii_txc),
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
    key_duts(
        .clk(sysc),
        .key(key[0]),
        .fs(fs_key),
        .fd(fd_key)
    );

endmodule