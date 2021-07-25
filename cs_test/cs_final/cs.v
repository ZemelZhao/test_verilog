module cs(
    // CLK
    input osc_clk,
    input net_clk,

    output sys_clk,
    output eth_clk
);


cs_clk
cs_clk_dut(
    .osc_clk(osc_clk),
    .net_clk(net_clk),

    .sys_clk(sys_clk),
    .eth_clk(eth_clk)
);

endmodule