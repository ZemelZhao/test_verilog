module mac2fifoc(
    //TEST
    input clk, 
    input rst,

    // CONTROL
    input fs,
    output fd,
    output [10:0] so,

    // MAC
    input [7:0] udp_rxd,
    output reg [10:0] udp_rx_addr,
    input [15:0] udp_rx_len,
    
    // FIFOC
    output [7:0] fifoc_txd,
    output reg fifoc_txen,
    output [11:0] dev_rx_len
);


    localparam IDLE = 8'h0, WORK = 8'h1, LAST = 8'h2;

    reg [15:0] data_cnt;

    reg [7:0] state, next_state;

    reg [15:0] reg_dev_rx_len;
    assign dev_rx_len = reg_dev_rx_len[11:0];

    assign fifoc_txd = udp_rxd;
    assign fd = (state == LAST);
    assign so = udp_rx_addr;

    always @(posedge clk or posedge rst) begin
        if(rst) reg_dev_rx_len <= 16'h0;
        else reg_dev_rx_len <= udp_rx_len - 16'h8;
    end


    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(fs) next_state <= WORK;
                else next_state <= IDLE;
            end
            WORK: begin
                if(udp_rx_addr == udp_rx_len - 16'h9) next_state <= LAST;
                else next_state <= WORK;
            end
            LAST: begin
                if(~fs) next_state <= IDLE;
                else next_state <= LAST;
            end
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) udp_rx_addr <= 11'h0;
        else if(state == WORK) udp_rx_addr <= udp_rx_addr + 1'b1;
        else udp_rx_addr <= 11'h0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) fifoc_txen <= 1'b0;
        else if(state == WORK) fifoc_txen <= 1'b1;
        else fifoc_txen <= 1'b0;
    end



endmodule
