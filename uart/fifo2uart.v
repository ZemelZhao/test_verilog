module fifo2uart(
    input clk,
    input rst,

    input fs,
    output fd,

    input uart_txdr,
    output uart_txdv,

    output fifo_rxen,
    input [7:0] data_len,
    
    input [7:0] fifo_rxd,
    output [7:0] uart_txd
);

    assign fifo_rxen = 1'b0;

    reg [3:0] state, next_state;
    localparam  IDLE = 4'h0, WORK = 4'h1, LAST = 4'h2;
    reg [7:0] cnt;
    
    assign fd = (state == LAST);
    assign uart_txdv = (state == WORK);
    assign uart_txd = cnt;
    assign fifo_rxen = 1'b0;

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
                if(cnt < data_len) next_state <= WORK;
                else next_state <= LAST;
            end
            LAST: begin
               if(fs == 1'b0) next_state <= IDLE;
               else next_state <= LAST;  
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) cnt <= 8'h0;
        else if(state == WORK && uart_txdr) cnt <= cnt + 1'b1;
        else if(state == WORK) cnt <= cnt;
        else cnt <= 8'h0;
    end

    



endmodule