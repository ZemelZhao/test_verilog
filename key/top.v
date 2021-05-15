module top(
    input sys_clk,

    input [3:0] key,
    output [3:0] led
);

    wire fs;
    assign led[0] = ~fs;
    assign led[3:1] = 3'b111;

    key 
    key_dut (
        .clk(sys_clk),
        .key(key),
        .fs(fs),
        .fd()
    );


endmodule