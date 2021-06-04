module top(
    input sys_clk,
    input rst_n,

    input [1:0] key,
    output [3:0] lec,
    output [31:0] led
);

    parameter LEN = 12'hC;
    localparam IDLE = 3'h0, FIWR = 3'h1, WAIT = 3'h2, FIRD = 3'h3;
    localparam LAST = 3'h4, LAT0 = 3'h5, LAT1 = 3'h6;

    wire rst;
    wire fs_fw, fs_fr;
    wire fd_fw, fd_fr;
    wire [95:0] data;
    wire [7:0] fifo_txd, fifo_rxd;
    wire fifo_txen, fifo_rxen;
    wire fsu, fdu, fsd, fdd;
    wire [3:0] num;
    wire fifo_full, fifo_empty;

    reg [2:0] state;
    assign rst = ~rst_n;
    assign num = 4'h2;
    assign fs_fw = (state == FIWR);
    assign fs_fr = (state == FIRD);

    always @(posedge sys_clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(~fifo_full) state <= FIWR;
                    else state <= IDLE;
                end
                FIWR: if(fd_fw) state <= WAIT;
                WAIT: state <= FIRD;
                FIRD: if(fd_fr) state <= LAST;
                LAST: state <= LAT0;
                LAT0: state <= LAT1;
                LAT1: state <= LAT1;
                default: state <= IDLE;
            endcase
        end
    end


    fifod
    fifod_dut(
        .rst(rst),
        .wr_clk(sys_clk),
        .wr_en(fifo_txen),
        .din(fifo_txd),
        .rd_clk(sys_clk),
        .rd_en(fifo_rxen),
        .dout(fifo_rxd),
        .full(fifo_full),
        .empty(fifo_empty)
    );

// FIFO
// #region
    fifo_write 
    fifo_write_dut(
        .clk(sys_clk),
        .rst(rst),
        .err(),
        .fifo_txd(fifo_txd),
        .fifo_txen(fifo_txen),
        .fs(fs_fw),
        .fd(fd_fw),
        .data_len(LEN)
    );

    fifo_read
    fifo_read_dut(
        .clk(sys_clk),
        .rst(rst),
        .err(),
        .FIFO_NUM(LEN),

        .fifo_rxd(fifo_rxd),
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

        .reg00(data[95:88]),
        .reg01(data[87:80]),
        .reg02(data[79:72]),
        .reg03(data[71:64]),
        .reg04(data[63:56]),
        .reg05(data[55:48]),
        .reg06(data[47:40]),
        .reg07(data[39:32]),
        .reg08(data[31:24]),
        .reg09(data[23:16]),
        .reg0A(data[15:8]),
        .reg0B(data[7:0])
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

    ilap
    ilap_dut(
        .clk(sys_clk),
        .probe0(fifo_txd),
        .probe1(fifo_rxd),
        .probe2(data),
        .probe3(state),
        .probe4(fs_fw),
        .probe5(fd_fw),
        .probe6(fs_fr),
        .probe7(fd_fr),
        .probe8(fifo_txen),
        .probe9(fifo_rxen),
        .probe10(fifo_full),
        .probe11(fifo_empty)
    );
// #endregion

endmodule