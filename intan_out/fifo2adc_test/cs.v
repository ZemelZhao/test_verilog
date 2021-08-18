module cs(
    input osc_clk,
    output sys_clk,
    output fifo_clk,

    input [7:0] kind_dev,
    output [9:0] adc_rx_len,
    output [11:0] eth_tx_len,
    output [7:0] adc_cnt,

    output [63:0] intan_cmd,
    output [63:0] intan_ind,
    output [7:0] intan_lrt,
    output [7:0] intan_end
);

    cs_num
    cs_num_dut(
        .clk(osc_clk),
        .cmd_kdev(kind_dev),

        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .data_cnt(adc_cnt),

        .intan_cmd(intan_cmd),
        .intan_ind(intan_ind),
        .intan_lrt(intan_lrt),
        .intan_end(intan_end)
    );




endmodule