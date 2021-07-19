module fifoc2cs ( // WRITE_DONE
    input clk,
    input rst,
    output reg err,

    input fs,
    output fd,

    output fifoc_rxen,
    input [7:0] fifoc_rxd,
    input [11:0] data_len,
    output reg [7:0] kind_dev,
    output [255:0] res,
    output [7:0] so,

    output reg [7:0] info_sr, // SAMPLE_RATE
    output reg [7:0] cmd_filt,
    output reg [7:0] cmd_mix0,
    output reg [7:0] cmd_mix1,
    output reg [7:0] cmd_reg4,
    output reg [7:0] cmd_reg5,
    output reg [7:0] cmd_reg6,
    output reg [7:0] cmd_reg7
);

    parameter NUM_LEN = 4'hC;

    reg [7:0] check;
    reg [11:0] fifo_num, addr;
    wire [1:0] judge;
    reg ju1, ju0;
    reg [0:255] cache;
    reg [7:0] state, next_state;
    localparam IDLE = 8'h00, PRE0 = 8'h01, PRE1 = 8'h02, WORK = 8'h03;
    localparam CHK0 = 8'h04, PREC = 8'h05, CHK1 = 8'h06;
    localparam EVAC = 8'h0E, LAST = 8'h0F;

    assign fd = (state == LAST);
    assign fifoc_rxen = (state == WORK || state == PRE1);
    assign judge = {ju1, ju0};
    assign res = cache;
    assign so = state;

    always@(posedge clk or posedge rst)begin // next_state => state
        if(rst)begin
            // state <= IDLE;
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always@(*) begin // state 
        case(state) 
            IDLE: begin
                if(fs) next_state <= PRE0;
                else next_state <= IDLE;
            end
            PRE0: begin
                next_state <= PRE1;
            end
            PRE1: begin
                next_state <= WORK;
            end
            WORK: begin
                if(fifo_num >= data_len) next_state <= CHK0;
                else next_state <= WORK;
            end
            CHK0: begin
                next_state <= PREC;
            end
            PREC: begin
                if(fifo_num == data_len - 2'h2) next_state <= CHK1;
                else next_state <= PREC;
            end
            CHK1: begin
                next_state <= EVAC;
            end
            EVAC: begin
                next_state <= LAST;
            end
            LAST: begin
                if(fs == 1'b0) next_state <= IDLE;
                else next_state <= LAST;
            end
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) ju1 <= 1'b0;
        else if(state == PRE0) ju1 <= 1'b0;
        else if(state == CHK0 && cache[0:15] == 16'h55AA) ju1 <= 1'b1;
        else if(state == CHK0 && cache[0:15] != 16'h55AA) ju1 <= 1'b0;
        else ju1 <= ju1;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) ju0 <= 1'b0;
        else if(state == PRE0) ju0 <= 1'b0;
        else if(state == CHK1 && check == cache[8*data_len-8 +: 8]) ju0 <= 1'b1;
        else if(state == CHK1 && check != cache[8*data_len-8 +: 8]) ju0 <= 1'b0;
        else ju0 <= ju0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) check <= 8'h00;
        else if(state == PREC) check <= check + cache[fifo_num*8 +: 8];
        else if(state == CHK0) check <= 8'h00;
        else check <= check;
    end

    always@(posedge clk or posedge rst) begin
        if(rst) err <= 1'b0;
        else if(state == EVAC && judge == 2'b11) err <= 1'b0;
        else if(state == EVAC && judge != 2'b11) err <= 1'b1;
        else err <= err;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            {kind_dev, info_sr, cmd_filt, 
             cmd_mix0, cmd_reg4, cmd_reg5, 
             cmd_reg6, cmd_reg7, cmd_mix1} <= 72'h000000_000000_000000;
        end
        else if(state == EVAC && judge == 2'b11) begin
            {kind_dev, info_sr, cmd_filt, 
             cmd_mix0, cmd_reg4, cmd_reg5, 
             cmd_reg6, cmd_reg7, cmd_mix1} <= cache[16:87];
        end
        else if(state == EVAC && judge != 2'b11) begin
            {kind_dev, info_sr, cmd_filt, 
             cmd_mix0, cmd_reg4, cmd_reg5, 
             cmd_reg6, cmd_reg7, cmd_mix1} <= 72'hFFFFFF_FFFFFF_FFFFFF;
        end
        else begin
            kind_dev <= kind_dev;
            info_sr <= info_sr;
            cmd_filt <= cmd_filt;
            cmd_mix0 <= cmd_mix0;
            cmd_mix1 <= cmd_mix1;
            cmd_reg4 <= cmd_reg4;
            cmd_reg5 <= cmd_reg5;
            cmd_reg6 <= cmd_reg6;
            cmd_reg7 <= cmd_reg7;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            addr <= 12'h0;
        end
        else if(state == WORK) begin
            addr <= addr + 4'h8;
        end
        else if(state == PRE0 || state == PRE1)begin
            addr <= 12'h0;
        end
        else begin
            addr <= addr;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) cache <= 256'h0;
        else cache[addr +: 8] <= fifoc_rxd;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            fifo_num <= 12'h000;
        end
        else if(state == PRE0 || state == PRE1 || state == WORK || state == PREC) begin
            fifo_num <= fifo_num + 1'b1;
        end
        else if(state == CHK0) begin
            fifo_num <= 12'h002;
        end
        else begin
            fifo_num <= 12'h000;
        end
    end


endmodule