module uart2fifo(
    input clk,
    input rst,

    input uart_rxdv,
    output uart_rxdr,

    input [7:0] uart_rxd,
    output [7:0] fifo_txd,

    output fifo_txen,
    input fd,
    output fs,

    output reg [7:0] data_len
);

    assign uart_rxdr = 1'b1;
    assign fifo_txd = uart_rxd;
    assign fifo_txen = (s == WORK);
    assign fs = (s == LAST);

    reg [3:0] s, ns;
    localparam IDLE = 4'h0, WORK = 4'h1, LAST = 4'h2;

    always @(posedge clk or posedge rst) begin
        if(rst) s <= IDLE;
        else s <= ns;
    end

    always @(*) begin
        case(s)
        IDLE: begin
            if(uart_rxdv) ns <= WORK;
            else ns <= IDLE;
        end
        WORK: begin
            if(uart_rxdv == 1'b0) ns <= LAST;
            else ns <= WORK;
        end
        LAST: begin
            if(fd) ns <= IDLE;
            else ns <= LAST;
        end
        default: ns <= IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) data_len <= 8'h0;
        else if(s == IDLE) data_len <= 8'h0;
        else if(s == WORK) begin
            data_len <= data_len + 1'b1;
        end
        else data_len <= data_len;
    end

endmodule
