module top
(
input                           sys_clk,       //system clock 50Mhz on board
input                           rst_n,        //reset ,low active
input                           uart_rx,      //fpga receive data
output                          uart_tx,      //fpga send data

input key,

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
    wire fs, fd;

    assign fifo_rxen = 1'b0;
    assign data_len = 8'd12;

    

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

    key 
    key_dut (
        .clk(sys_clk),
        .key(key),
        .fs(fs),
        .fd(fd)
    );
        
    fifo2uart 
    fifo2uart_dut(
        .clk(sys_clk),
        .rst(rst),
        .fs(fs),
        .fd(fd),
        .uart_txdr(uart_txdr),
        .uart_txdv(uart_txdv),
        .fifo_rxen(fifo_rxen),
        .data_len(data_len),
        .fifo_rxd(fifo_rxd),
        .uart_txd(uart_txd)
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
