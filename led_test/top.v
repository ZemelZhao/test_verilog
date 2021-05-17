module top(
    input sys_clk,
    output [31:0] led
);

assign led[31:24] = ~8'hF8;
assign led[23:16] = ~8'hE9;
assign led[15:8] = ~8'hDA;
assign led[7:0] = ~8'hCB;

endmodule