module cs_clk(
    input osc_clk,
    input net_clk,

    output sys_clk,
    output eth_clk
);

    clkf_sys
    clkf_sys_wiz(
        .clk_out1(sys_clk),
        .reset(1'b0),
        .locked(),
        .clk_in1(osc_clk)
    );

    clkf_eth
    clkf_eth_wiz(
        .clk_out1(eth_clk),
        .reset(1'b0),
        .locked(),
        .clk_in1(net_clk)
    );




endmodule
