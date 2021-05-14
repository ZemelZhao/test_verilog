module fifo2uart(
    input clk,
    input rst,

    input fs,
    output fd,

    input uart_txdr,
    output uart_txdv,

    output fifo_rxen,
    input [7:0] data_len,
    
    input [7:0] fifo_rxd,
    output [7:0] uart_txd
);


endmodule