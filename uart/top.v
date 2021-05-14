module top
(
input                           sys_clk,       //system clock 50Mhz on board
input                           rst_n,        //reset ,low active
input                           uart_rx,      //fpga receive data
output                          uart_tx,      //fpga send data

output lec,
output [3:0] led
);
    localparam CLK_FRE = 50;

    wire rst;
    wire [7:0] uart_rxd;
    wire uart_rxdv, uart_rxdr;
    wire [7:0] uart_txd;
    wire uart_txdv, uart_txdr;
    assign rst = ~rst_n;

    wire fifo_txen;
    wire [7:0] fifo_txd;
    wire fifo_rxen;
    wire [7:0] fifo_rxd;

    wire [7:0] data_len;

    assign fifo_rxen = 1'b0;

    

    uart_rx#
    (
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(115200)
    ) uart_rx_inst
    (
        .clk                        (sys_clk                  ),
        .rst_n                      (rst_n                    ),
        .rx_data                    (uart_rxd                 ),
        .rx_data_valid              (uart_rxdv                ),
        .rx_data_ready              (uart_rxdr                ),
        .rx_pin                     (uart_rx                  )
    );

    uart_tx#
    (
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(115200)
    ) uart_tx_inst
    (
        .clk                        (sys_clk                  ),
        .rst_n                      (rst_n                    ),
        .tx_data                    (uart_txd                 ),
        .tx_data_valid              (uart_txdv                ),
        .tx_data_ready              (uart_txdr                ),
        .tx_pin                     (uart_tx                  )
    );

/***************************************************************************
ADD
****************************************************************************/

    fifo
    fifo_dut(
        .wr_clk(sys_clk),
        .wr_en(fifo_txen),
        .din(fifo_txd),
        .rd_clk(sys_clk),
        .rd_en(fifo_rxen),
        .dout(fifo_rxd),
        .rst(rst)
    );

    uart2fifo 
    uart2fifo_dut (
        .clk(sys_clk),
        .rst(rst),
        .uart_rxdv(uart_rxdv),
        .uart_rxdr(uart_rxdr),
        .uart_rxd(uart_rxd),
        .fifo_txd(fifo_txd),
        .fifo_txen(fifo_txen),
        .fd(),
        .fs(),
        .data_len(data_len)
    );

    led 
    led_dut (
        .sys_clk(sys_clk),
        .rst(rst),
        .data(data_len),
        .lec(lec),
        .led(led)
    );




endmodule
