//////////////////////////////////////////////////////////////////////////////////
// Module Name:    ethernet_test 
//////////////////////////////////////////////////////////////////////////////////
module test
(
    input clk,                         //system clock 50Mhz on board
    input rst_n,                           //reset ,low active
    output e_mdc,                           //phy emdio clock
    inout e_mdio,                          //phy emdio data
    output[3:0] rgmii_txd,                       //phy data send
    output rgmii_txctl,                     //phy data send control
    output rgmii_txc,                       //Clock for sending data
    input[3:0] rgmii_rxd,                       //recieve data
    input rgmii_rxctl,                     //Control signal for receiving data
    input rgmii_rxc,                        //Clock for recieving data
    
    input key, 
    output [3:0] led,
    output led_test
);

parameter TEST_ORDER = 4'h1;
wire test_show = fs_tx;

wire udp_tx_end;
wire mac_send_end;
// RST
wire rst;

// CLK
wire gmii_tx_clk;
wire gmii_rx_clk;

// ETH
wire gmii_rx_dv;
wire [7:0] gmii_rxd;
wire gmii_tx_en;
wire [7:0] gmii_txd;

wire mac_rx_dv;
wire [7:0] mac_rxd;
wire mac_tx_dv;
wire [7:0] mac_txd;

// MAC
wire [7:0] mac_ttl;
wire [47:0] src_mac_addr;
wire [31:0] src_ip_addr;
wire [31:0] src_port;
wire [31:0] det_ip_addr;
wire [31:0] det_port;

// FIFO_TX
wire flag_udp_tx_prep, flag_udp_tx_req;
wire udp_txen;
wire [7:0] udp_txd;
reg fs_udp_tx;
wire fd_udp_tx;

// FIFO_RX
wire fd_udp_rx;
wire fs_udp_rx;
wire [7:0] udp_rxd;
wire [10:0] udp_rx_addr;
wire [15:0] udp_rx_len;

// FIFOD
wire clk_fifod_tx;
wire clk_fifod_rx;
wire [7:0] fifo_txd, fifo_rxd;
wire fifo_txen, fifo_rxen;
wire [11:0] data_len;

// TEST
wire [3:0] led_show;

// CONTROL
reg [31:0] data_cnt;
reg fs_tx;
wire fd_tx;
localparam TIME = 32'd5_000_000;

assign rst = ~rst_n;
assign mac_ttl = 8'h80;
assign src_mac_addr = 48'h00_0A_35_01_FE_C0;
assign src_ip_addr = 32'hC0_A8_00_02;
assign src_port = 32'd8080;
assign det_ip_addr = 32'hC0_A8_00_03;
assign det_port = 32'd8080;

assign led = ~TEST_ORDER;
assign led_test = ~test_show;

assign clk_fifod_tx = clk;
assign clk_fifod_rx = clk;
assign fd_udp_rx = 1'b0;


always @(posedge clk or posedge rst) begin
    if(rst) fs_udp_tx <= 1'b0;
    else if(fd_udp_rx) fs_udp_tx <= 1'b1;
    else if(fd_udp_tx) fs_udp_tx <= 1'b0;
    else fs_udp_tx <= fs_udp_tx;
end


eth 
eth_dut (
    .e_mdc (e_mdc ),
    .e_mdio (e_mdio ),
    .rgmii_txd (rgmii_txd ),
    .rgmii_txctl (rgmii_txctl ),
    .rgmii_txc (rgmii_txc ),
    .rgmii_rxd (rgmii_rxd ),
    .rgmii_rxctl (rgmii_rxctl ),
    .rgmii_rxc (rgmii_rxc ),
    .gmii_tx_clk (gmii_tx_clk ),
    .gmii_rx_clk (gmii_rx_clk ),
    .gmii_rx_dv (gmii_rx_dv ),
    .gmii_rxd (gmii_rxd ),
    .gmii_tx_en (gmii_tx_en ),
    .gmii_txd  ( gmii_txd)
);

eth2mac 
eth2mac_dut (
    .rst (rst ),
    .gmii_tx_clk (gmii_tx_clk ),
    .gmii_rx_clk (gmii_rx_clk ),
    .gmii_rx_dv (gmii_rx_dv ),
    .gmii_rxd (gmii_rxd ),
    .mac_rx_dv (mac_rx_dv ),
    .mac_rxd (mac_rxd ),
    .gmii_tx_en (gmii_tx_en ),
    .gmii_txd (gmii_txd ),
    .mac_tx_dv (mac_tx_dv ),
    .mac_txd  ( mac_txd)
);

fifod2mac 
fifod2mac_dut (
    .clk (gmii_tx_clk),
    .rst (rst ),
    .fs (fs_udp_tx ),
    .fd (fd_udp_tx ),

    .data_len (data_len ),

    .fifod_rxen (fifo_rxen ),
    .fifod_rxd (fifo_rxd ),

    .flag_udp_tx_prep (flag_udp_tx_prep ),
    .flag_udp_tx_req (flag_udp_tx_req ),
    .udp_txen (udp_txen ),
    .udp_txd  (udp_txd)
);

mac 
mac_dut (
    .gmii_tx_clk (gmii_tx_clk ),
    .gmii_rx_clk (gmii_rx_clk ),
    .rst (rst ),
    .mac_ttl (mac_ttl ),
    .src_mac_addr (src_mac_addr ),
    .src_ip_addr (src_ip_addr ),
    .src_port (src_port ),
    .det_ip_addr (det_ip_addr ),
    .det_port (det_port ),
    .mac_rx_dv (mac_rx_dv ),
    .mac_rxd (mac_rxd ),
    .mac_tx_dv (mac_tx_dv ),
    .mac_txd (mac_txd ),

    .fs_udp_tx(fs_udp_tx),
    .fd_udp_tx(fs_udp_tx),

    .udp_tx_len (data_len ),
    .flag_udp_tx_req (flag_udp_tx_req ),
    .flag_udp_tx_prep (flag_udp_tx_prep ),
    .udp_txen (udp_txen),
    .udp_txd(udp_txd),

    .fs_udp_rx(fs_udp_rx),
    .fd_udp_rx(fd_udp_rx),
    .udp_rxd(udp_rxd),
    .udp_rx_addr(udp_rx_addr),
    .udp_rx_len(udp_rx_len)
);


fifod 
fifod_dut(
    .wr_clk(gmii_rx_clk),
    .rd_clk(gmii_tx_clk),
    .rst(rst),
    .din(fifo_txd),
    .wr_en(fifo_txen),
    .dout(fifo_rxd),
    .rd_en(fifo_rxen)
);

mac2fifoc 
mac2fifoc_dut(
    .clk(gmii_rx_clk),
    .rst(rst),

    .fs(fs_udp_rx),
    .fd(fd_udp_rx),

    .udp_rxd(udp_rxd),
    .udp_rx_addr(udp_rx_addr),
    .udp_rx_len(udp_rx_len),

    .fifoc_txd(fifo_txd),
    .fifoc_txen(fifo_txen),
    .dev_rx_len(data_len)
);



endmodule

