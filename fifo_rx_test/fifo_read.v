module fifo_read(
    input clk,
    input rst,
    input err,
    output [2:0] so,
    input [11:0] FIFO_NUM,

    input [7:0] fifo_rxd,
    output fifo_rxen,
    output reg [0 : 95] res,

    input fs,
    output fd
);

    reg [2:0] state, next_state;
    localparam [2:0] IDLE = 3'h0, PRE0 = 3'h1, PRE1 = 3'h2;
    localparam [2:0] WORK = 3'h3, LAST = 3'h4;
    assign so = state;

    reg [15:0] addr;  

    reg [11:0] fifo_num;
    assign fd = (state == LAST);
    assign fifo_rxen = (state == WORK || state == PRE1);

    always @(negedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if(fs) begin
                    next_state <= PRE0;
                end
            end
            PRE0: begin
                next_state <= PRE1;
            end
            PRE1: begin
                next_state <= WORK;
            end
            WORK: begin
                if(fifo_num == FIFO_NUM + 1'b1) begin
                    next_state <= LAST;
                end
                else next_state <= WORK;
            end
            LAST: begin
                if(fs == 1'b0) begin
                    next_state <= IDLE;
                end
                else next_state <= LAST;
            end
            default: begin
                next_state <= IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            addr <= 16'h0;
        end
        else if(state == WORK) begin
            addr <= addr + 16'h1;
        end
        else if(state == PRE0 || state == PRE1)begin
            addr <= 16'h0;
        end
        else begin
            addr <= addr;
        end
        
    end

    always @(posedge clk or posedge rst) begin
        if(rst) res <= 96'h0;
        else res[addr*8 +: 8] <= fifo_rxd;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            fifo_num <= 12'h000;
        end
        else if(state == PRE0 || state == PRE1 || state == WORK) begin
            fifo_num <= fifo_num + 1'b1;
        end
        else begin
            fifo_num <= 12'h000;
        end
    end

endmodule
    
