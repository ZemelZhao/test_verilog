module top(
    input sys_clk,
    input rst_n,

    input [1:0] key,
    output [3:0] lec,
    output [31:0] led
);

    parameter LEN = 12'hC;

    wire rst;
    wire fs_fw, fs_fr, fd_fw, fd_fr;
    wire [95:0] data;
    wire [7:0] fifo_txd, fifo_rxd;
    wire fifo_txen, fifo_rxen;
    wire fsu, fdu, fsd, fdd;
    assign rst = ~rst_n;

    fifod
    fifod_dut(
        .rst(rst),
        .wr_clk(sys_clk),
        .wr_en(fifo_txen),
        .din(fifo_txd),
        .rd_clk(sys_clk),
        .rd_en(fifo_rxen),
        .dout(fifo_rxd)
    );

// FIFO
// #region
    fifo_write 
    fifo_write_dut(
        .clk(sys_clk),
        .rst(rst),
        .err(),
        .dout(fifo_txd),
        .fifo_txen(fifo_txen),
        .fs(fs_fw),
        .fd(fd_fw),
        .data_len(LEN)
    );

    fifo_read#(LEN)
    fifo_read_dut(
        .clk(sys_clk),
        .rst(rst),
        .err(),
        .din(fifo_rxd),
        .fifo_rxen(fifo_rxen),
        .res(data),
        .fs(fs_fr),
        .fd(fd_fr)
    );


// #endregion

// LED
// # region
    led
    led_dut(
        .clk(sys_clk),
        .rst(~rst_n),
        .num(num),
        .lec(lec),
        .led(led),
        .fsu(fsu),
        .fsd(fsd),
        .fdu(fdu),
        .fdd(fdd),

        .reg00(data[7:0]),
        .reg01(data[15:8]),
        .reg02(data[23:16]),
        .reg03(data[31:24]),
        .reg04(data[39:32]),
        .reg05(data[47:40]),
        .reg06(data[55:48]),
        .reg07(data[63:56]),
        .reg08(data[71:64]),
        .reg09(data[79:72]),
        .reg0A(data[87:80]),
        .reg0B(data[95:88]),
    );

    key 
    key_dutu(
        .clk(sys_clk),
        .key(key[1]),
        .fs(fsu),
        .fd(fdu)
    );

    key 
    key_dutd(
        .clk(sys_clk),
        .key(key[0]),
        .fs(fsd),
        .fd(fdd)
    );
// #endregion

endmodule