module clk_factory(
    input cin,
    output sysc,
    output fifo_txc,
    output fifo_rxc,
    output ilac
);

    wire fifoc;

    assign fifo_txc = fifoc;
    assign fifo_rxc = fifoc;

    clkf
    clkf_dut(
        .clk_in1(cin),
        .clk_out1(ilac),
        .clk_out2(fifoc),
        .clk_out3(sysc)
    );





endmodule