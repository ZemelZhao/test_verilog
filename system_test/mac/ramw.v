module ramw(
    input clk,
    input rst,
    input [95:0] data,

    input fs,
    output fd,
    input fifoe_full,
    output [7:0] so,

    output reg fifoe_txen,
    output reg [7:0] fifoe_txd
);
    reg [7:0] state, next_state;
    wire [7:0] dat[11:0];

    localparam IDLE = 8'h00, PREP = 8'h01, BEGN = 8'h02;
    localparam DAT0 = 8'h10, DAT1 = 8'h11, DAT2 = 8'h12, DAT3 = 8'h13;
    localparam DAT4 = 8'h14, DAT5 = 8'h15, DAT6 = 8'h16, DAT7 = 8'h17;
    localparam DAT8 = 8'h18, DAT9 = 8'h19, DATA = 8'h1A, DATB = 8'h1B;
    localparam LAST = 8'h80;

    assign dat[11] = data[95:88];
    assign dat[10] = data[87:80];
    assign dat[9] = data[79:72];
    assign dat[8] = data[71:64];
    assign dat[7] = data[63:56];
    assign dat[6] = data[55:48];
    assign dat[5] = data[47:40];
    assign dat[4] = data[39:32];
    assign dat[3] = data[31:24];
    assign dat[2] = data[23:16];
    assign dat[1] = data[15:8];
    assign dat[0] = data[7:0];
    assign fd = (state == LAST);
    assign so = state;

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(~fifoe_full) next_state <= PREP;
                else next_state <= IDLE;
            end
            PREP: begin
                if(fs) next_state <= BEGN;
                else next_state <= PREP;
            end
            BEGN: next_state <= DAT0;
            DAT0: next_state <= DAT1;
            DAT1: next_state <= DAT2;
            DAT2: next_state <= DAT3;
            DAT3: next_state <= DAT4;
            DAT4: next_state <= DAT5;
            DAT5: next_state <= DAT6;
            DAT6: next_state <= DAT7;
            DAT7: next_state <= DAT8;
            DAT8: next_state <= DAT9;
            DAT9: next_state <= DATA;
            DATA: next_state <= DATB;
            DATB: next_state <= LAST;
            LAST: begin
                if(~fs) next_state <= IDLE;
                else next_state <= LAST;
            end
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(state == IDLE) begin
            fifoe_txen <= 1'b0;
            fifoe_txd <= 8'h00;
        end
        else if(state == DAT0) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[11];
        end
        else if(state == DAT1) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[10];
        end
        else if(state == DAT2) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[9];
        end
        else if(state == DAT3) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[8];
        end
        else if(state == DAT4) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[7];
        end
        else if(state == DAT5) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[6];
        end
        else if(state == DAT6) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[5];
        end
        else if(state == DAT7) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[4];
        end
        else if(state == DAT8) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[3];
        end
        else if(state == DAT9) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[2];
        end
        else if(state == DATA) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[1];
        end
        else if(state == DATB) begin
            fifoe_txen <= 1'b1;
            fifoe_txd <= dat[0];
        end
        else begin
            fifoe_txen <= 1'b0;
            fifoe_txd <= 8'h00;
        end
    end



endmodule