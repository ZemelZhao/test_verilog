module top(
    input clk,
    input rst_n,
    input [7:0] dk,
    output [23:0] led
);

    wire [9:0] adc_rx_len;
    wire [11:0] eth_tx_len;

    wire [23:0] res;

    wire fs, fd;

    assign fs = 1'b1;
    assign led = {9'b0, adc_rx_len, eth_tx_len, fd};


    cs_num
    cs_num_dut(
        .clk(clk),
        .rst(~rst_n),
        .cmd_kdev(dk),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .fs(fs),
        .fd(fd)
    );
endmodule