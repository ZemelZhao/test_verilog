module top();

reg clk, fs, rst;

reg [7:0] cmd_kdev;

wire [9:0] adc_rx_len;
wire [11:0] eth_tx_len;
wire [7:0] data_cnt;
wire fd;


always begin
    clk <= 1'b0;
    #5;
    clk <= 1'b1;
    #5;
end

initial begin
    rst <= 1'b0;
    
end


    cs_num 
    cs_num_dut (
        .clk(clk),
        .rst(rst),
        .cmd_kdev(cmd_kdev),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .data_cnt(data_cnt),
        .fs(fs),
        .fd(fd)
    );



endmodule