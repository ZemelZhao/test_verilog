module fifo_write
(
    input clk,
    input rst,
    input err,
    
    input [7:0] din,

    output [7:0] dout,
    output fifo_txen,

    input fs,
    output fd,
    input [11:0] data_len
);


    wire[7:0] cache_data[127:0];  
    reg [2:0] state, next_state;

    localparam [2:0] IDLE = 3'h0, LAST = 3'h3, HEAD = 3'h4;
    localparam [2:0] WOK0 = 3'h5, WOK1 = 3'h6, WOK2 = 3'h7;

    localparam HEAD_LEN = 8'h4, TAIL_LEN = 8'h2;

    reg [11:0] bag_num, fifo_num;
    assign fd = (state == LAST);
    assign fifo_txen = ((state >= WOK0));
    assign dout = cache_data[bag_num];

    assign cache_data[0] = 8'h55;
    assign cache_data[1] = 8'hAA;
    assign cache_data[2] = din;
    assign cache_data[3] = din + 2'h1;
    assign cache_data[4] = 8'h66;
    assign cache_data[5] = 8'hBB;

    

    always @(posedge clk or posedge rst) begin
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
                    next_state <= HEAD;
                end
                else begin
                    next_state <= IDLE;
                end
            end
            HEAD: begin
                next_state <= WOK0;
            end
            WOK0: begin
                if(fifo_num == (HEAD_LEN - 2'h1)) begin
                    next_state <= WOK1;
                end
                else next_state <= WOK0;
            end
            WOK1: begin
                if(fifo_num == (data_len - 2'h1 - HEAD_LEN)) begin
                    next_state <= WOK2;
                end
                else next_state <= WOK1;
            end
            WOK2: begin
                if(fifo_num == (data_len - 2'h1)) next_state <= LAST;
                else next_state <= WOK2;
            end
            LAST: begin
                if(fs == 1'b0) begin
                    next_state <= IDLE;
                end
            end
            default: begin
                next_state <= IDLE;
            end
        endcase
    end


    always @(posedge clk or posedge rst) begin
        if(rst) begin
            fifo_num <= 12'h000;
        end
        else if(state == HEAD) begin
            fifo_num <= 12'h000;
        end
        else if(fifo_txen) begin
            fifo_num <= fifo_num + 1'b1;
        end
        else begin
            fifo_num <= 12'h000;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            bag_num <= 12'h000;
        end
        else if(fifo_txen) begin
            bag_num <= bag_num + 1'b1;
        end
        else if(state == HEAD)begin
            bag_num <= 12'h000;
        end
        else begin
            bag_num <= 12'h000;
        end
    end

endmodule
    
