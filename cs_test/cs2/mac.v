// ## 0. DOCUMENT SECTION
// #region 
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//      Author: ZemZhao                                                         //
//      E-mail: zemzhao@163.com                                                 //
//      Please feel free to contact me if there are BUGs in my program.         //
//      For I know they are everywhere.                                         //
//      I can do nothing but encourage you to debug desperately.                //
//      GOOD LUCK, HAVE FUN!!                                                   //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                              SJTU BCI-Lab 205                                //
//                            All rights reserved                               //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
// mac.v:
// 该文件在

// ## 1. 具体功能
// * 

// ## 2. 变量综述
// * fifo_rxen 
// * up_txen 
// *  

// ! 这个还是有一个问题，在发送多次数据之后，会出现无法继续运行的问题
// ! 现在怀疑是flag_udp_tx_prep在多次发送之后未准备完成
// ! 究其原因，就是udp_tx中的fifo满了，导致后面的问题，但是这个问题现在还没法修改

//////////////////////////////////////////////////////////////////////////////////
// #endregion 

module mac(
    output [3:0] so,
    input gmii_txc,
    input gmii_rxc,
    input rst,     

    // MAC_INFO
    input [7:0] mac_ttl,
    input [47:0] src_mac_addr,
    input [31:0] src_ip_addr,
    input [31:0] src_port,
    input [31:0] det_ip_addr,
    input [31:0] det_port,

    // ETH
    input mac_rxdv,
    input [7:0] mac_rxd,
    output mac_txdv,
    output [7:0] mac_txd,

    // UDP_TX
    input fs_udp_tx,
    input fd_udp_tx,

    input [11:0] udp_tx_len,
    input flag_udp_tx_req,
    input udp_txen,
    output flag_udp_tx_prep,
    input [7:0] udp_txd,

    // UDP_RX
    output fs_udp_rx,
    input fd_udp_rx, 

    output [7:0] udp_rxd,
    input [10:0] udp_rx_addr,
    output [15:0] udp_rx_len
);


localparam IDLE = 4'h0;
localparam ARP_REQ = 4'h1, ARP_SEND = 4'h2, ARP_WAIT = 4'h3;
localparam ARP_NAP0 = 4'h4, ARP_NAP = 4'h5, ARP_CHECK = 4'h6;
localparam WAIT = 4'h7;
localparam SEND = 4'h8, RECV = 4'h9;

reg [31:0] wait_cnt;
reg [11:0] tx_len;

wire arp_request_req;
wire flag_almost_full;

wire udp_tx_end;
wire mac_send_end;
wire arp_found;
wire mac_not_exist;
wire flag_udp_rxdv;

reg [3:0] state, next_state;
assign fs_udp_rx = (state == RECV);
assign arp_request_req = (state == ARP_REQ);
assign so = state;


always @(posedge gmii_txc or posedge rst) begin
    if(rst) state <= IDLE;
    else state <= next_state;
end

always @(*) begin
    case (state)
        IDLE: begin
            if(wait_cnt == 32'd125_000_000) next_state <= ARP_REQ;
            else next_state <= IDLE;
        end
        ARP_REQ: begin
            next_state <= ARP_SEND;
        end
        ARP_SEND: begin
            if(mac_send_end) next_state <= ARP_WAIT;
            else next_state <= ARP_SEND; 
        end
        ARP_WAIT: begin
            if(arp_found) next_state <= ARP_NAP0;
            else if(wait_cnt == 32'd125_000_000) next_state <= ARP_REQ;
            else next_state <= ARP_WAIT;
        end
        ARP_NAP0: next_state <= ARP_NAP;
        ARP_NAP: begin
            if(wait_cnt == 32'd90) next_state <= ARP_CHECK;
            else next_state <= ARP_NAP;
        end
        ARP_CHECK: begin
            if(mac_not_exist) next_state <= ARP_REQ;
            else if(flag_almost_full) next_state <= ARP_CHECK;
            else next_state <= WAIT;
        end
        WAIT: begin
            if(fs_udp_tx) next_state <= SEND;
            else if(flag_udp_rxdv) next_state <= RECV;
            else next_state <= WAIT;
        end
        SEND: begin
            if(fd_udp_tx) next_state <= ARP_NAP;
            else next_state <= SEND;
        end
        RECV: begin
            if(fd_udp_rx) next_state <= ARP_NAP;
            else next_state <= RECV;
        end
        default: next_state <= IDLE;
    endcase
end

always @(posedge gmii_txc or posedge rst) begin
    if(rst) wait_cnt <= 32'h0;
    else if(state == IDLE || state == ARP_WAIT || state == ARP_NAP ) wait_cnt <= wait_cnt + 1'b1;
    else wait_cnt <= 32'h0;
end


mac_top mac_top0(
	.gmii_tx_clk				 (gmii_txc),
	.gmii_rx_clk                 (gmii_rxc),
	.rst_n                       (~rst),
	
	.source_mac_addr             (src_mac_addr),
	.TTL                         (mac_ttl),
	.source_ip_addr              (src_ip_addr),
	.destination_ip_addr         (det_ip_addr),
	.udp_send_source_port        (src_port),
	.udp_send_destination_port   (det_port),

	.mac_data_valid              (mac_txdv),
	.mac_tx_data                 (mac_txd),
	.rx_dv                       (mac_rxdv),
	.mac_rx_datain               (mac_rxd),
	
	.ram_wr_data                 (udp_txd),
	.ram_wr_en                   (udp_txen),
	.udp_send_data_length        (udp_tx_len),
	.udp_tx_end                  (udp_tx_end),
	.udp_ram_data_req            (flag_udp_tx_prep),
	.udp_tx_req                  (flag_udp_tx_req),
	.almost_full                 (flag_almost_full), 

	.udp_rec_ram_rdata           (udp_rxd),
	.udp_rec_ram_read_addr       (udp_rx_addr),
	.udp_rec_data_length         (udp_rx_len),
	.udp_rec_data_valid          (flag_udp_rxdv),

	.arp_request_req             (arp_request_req),
	.mac_send_end                (mac_send_end),
	.arp_found                   (arp_found),
	.mac_not_exist               (mac_not_exist)
);

endmodule