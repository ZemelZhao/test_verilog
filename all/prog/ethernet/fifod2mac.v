module fifod2mac(
    input clk,
    input rst,

    input fs,
    output fd,

    input [11:0] data_len,

    output fifod_rxen,
    input [7:0] fifod_rxd,
    output reg udp_txen,
    output [7:0] udp_txd,

    input flag_udp_tx_prep,
    output flag_udp_tx_req
);


localparam IDLE = 4'h0, MAC_REQ = 4'h1, WORK = 4'h2, LAST = 4'h3;

reg [11:0] tx_len;

reg [3:0] state, next_state;

assign flag_udp_tx_req = (state == MAC_REQ);
assign fifod_rxen = (state == WORK);
assign fd = (state == LAST);
assign udp_txd = fifod_rxd;


always @(posedge clk or posedge rst) begin
    if(rst) state <= IDLE;
    else state <= next_state;
end

always @(*) begin
    case (state)
        IDLE: begin
            if(fs) next_state <= MAC_REQ;
            else next_state <= IDLE;
        end
        MAC_REQ: begin
            if(flag_udp_tx_prep) next_state <= WORK;
            else next_state <= MAC_REQ;
        end
        WORK: begin
            if(tx_len == data_len - 1'b1) next_state <= LAST;
            else next_state <= WORK;
        end
        LAST: begin
            if(fs == 1'b0) next_state <= IDLE;
            else next_state <= LAST;
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst) tx_len <= 12'h0;
    else if(state == WORK) tx_len <= tx_len + 1'b1;
    else tx_len <= 12'h0;
end

always @(posedge clk or posedge rst) begin
    if(rst) udp_txen <= 1'b0;
    else if(state == WORK) udp_txen <= 1'b1;
    else udp_txen <= 1'b0;
end


endmodule