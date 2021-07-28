module top(
    input clk,

    input [3:0] key,
    output [3:0] lec,
    output [31:0] led

);

    localparam VERSION = 8'h02;
    assign led[31:24] = ~VERSION;

    reg [7:0] state, next_state;
    wire fs;
    reg [3:0] led_cont;

    localparam IDLE = 8'h00, WORK = 8'h01, LAST = 8'h02;
    localparam START = 8'h03;

    assign lec = ~led_cont;

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                next_state <= START;
            end
            START: begin
                if(fs) next_state <= WORK;
                else next_state <= START;
            end
            WORK: begin
                next_state <= LAST;
            end
            LAST: begin
                if(~fs) next_state <= START;
                else next_state <= LAST;
            end
        endcase
    end

    always @(posedge clk) begin
        if(state == IDLE) led_cont <= 4'h0;
        else if(state == WORK) led_cont <= led_cont + 1'b1;
        else led_cont <= led_cont;
    end



    key
    key_dut(
        .clk(clk),
        .key(key[0]),
        .fs(fs)
    );

endmodule