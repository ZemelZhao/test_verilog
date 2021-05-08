module top(
    input sys_clk,
    output lec,
    output [3:0] led
);

localparam LED_SHOW = 4'b1101;

assign led = LED_SHOW;
assign lec = 1'b0;

endmodule