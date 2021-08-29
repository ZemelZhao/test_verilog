module test(
    input clk,
    output [15:0] led
);
    localparam LED = 16'h789A;

    assign led = ~LED;



endmodule