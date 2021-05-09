module top(
    input sys_clk,

    input [3:0] key,
    output [3:0] led
);

assign led = key;

endmodule