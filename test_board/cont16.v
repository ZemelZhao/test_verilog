module cont(
    input clk,
    input [1:0] key,
    output [15:0] dout,
    output [15:0] sout
);


    parameter BIT_NUM = 8'h10;

    wire fs_tran, fs_bit;

    reg [3:0] num;
    reg [15:0] data;
    reg [15:0] show;

    reg [7:0] state, next_state;
    
    localparam IDLE = 8'h0, PREP = 8'h1, FSTR = 8'h2, FSBT = 8'h3;
    assign dout = data;
    assign sout = show;


    key
    key_tran(
        .clk(clk),
        .key(key[1]),
        .fs(fs_tran)
    );

    key
    key_bit(
        .clk(clk),
        .key(key[0]),
        .fs(fs_bit)
    );

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                next_state <= PREP;
            end
            PREP: begin
                if(fs_tran) next_state <= FSTR;
                else if(fs_bit) next_state <= FSBT;
                else next_state <= PREP;
            end
            FSTR: begin
                if(~fs_tran) next_state <= PREP;
                else next_state <= FSTR;
            end
            FSBT: begin
                if(~fs_bit) next_state <= PREP;
                else next_state <= FSBT;
            end
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(state == IDLE) num <= 4'h0;
        else if(state == PREP && next_state == FSTR) begin
            if(num == 4'hF) num <= 4'h0;
            else num <= num + 1'b1;
        end
        else num <= num;
    end

    always @(posedge clk) begin
        if(state == IDLE) data <= 16'h0;
        else if(state == PREP && next_state == FSBT) data[num] = ~data[num];
        else data <= data;
    end

    always @(*) begin
        case(num)
            4'h0: show <= 16'h0001;
            4'h1: show <= 16'h0002;
            4'h2: show <= 16'h0004;
            4'h3: show <= 16'h0008;
            4'h4: show <= 16'h0010;
            4'h5: show <= 16'h0020;
            4'h6: show <= 16'h0040;
            4'h7: show <= 16'h0080;
            4'h8: show <= 16'h0100;
            4'h9: show <= 16'h0200;
            4'hA: show <= 16'h0400;
            4'hB: show <= 16'h0800;
            4'hC: show <= 16'h1000;
            4'hD: show <= 16'h2000;
            4'hE: show <= 16'h4000;
            4'hF: show <= 16'h8000;
            default: show <= 16'h0001;
        endcase
    end
    



endmodule