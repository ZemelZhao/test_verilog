module top(
    input clk,
    input [3:0] key,
    output [3:0] lec,
    output [31:0] led
);

    localparam VERSION = 4'h1;
    assign lec = ~VERSION;

    assign led = ~{data, show, 16'h0};

    wire [7:0] data, show;

    cont
    cont_dut(
        .clk(clk),
        .key(key[1:0]),
        .dout(data),
        .sout(show)
    );


endmodule