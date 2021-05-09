module top(
    input sys_clk,
    input rstn,

    output lec,
    output [3:0] led
);

    localparam DATA = 7'h5B;

    led 
    led_dut (
        .sys_clk(sys_clk),
        .rst(~rstn),
        .data(DATA),
        .lec(lec),
        .led(led)
    );



endmodule