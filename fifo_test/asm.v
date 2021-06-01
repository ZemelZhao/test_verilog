module asm();

    parameter LEN = 12'hC;
    localparam IDLE = 3'h0, FIWR = 3'h1, WAIT = 3'h2, FIRD = 3'h3, LAST = 3'h4;
    reg sys_clk;
    reg rst;
    wire fs_fw, fs_fr;
    wire fd_fw, fd_fr;
    wire [95:0] data;
    wire [7:0] fifo_txd, fifo_rxd;
    wire fifo_txen, fifo_rxen;
    wire fsu, fdu, fsd, fdd;
    wire [3:0] num;
    wire [3:0] state_fw;
    wire [3:0] state_fr;
    wire [11:0] fifo_num_fw;
    wire judge_fw;
    wire [11:0] num_fw;
    wire [9:0] fifo_rxnum, fifo_txnum;
    wire fifo_empty, fifo_full;

    reg [2:0] state;
    assign num = 4'h2;
    assign fs_fw = (state == FIWR);
    assign fs_fr = (state == FIRD);

    always begin
        sys_clk <= 1'b0;
        #5;
        sys_clk <= 1'b1;
        #5;
    end

    initial begin
        rst <= 1'b0;
        #21;
        rst <= 1'b1;
        #10;
        rst <= 1'b0;
    end

    always @(posedge sys_clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(fifo_full == 1'b0) state <= FIWR;
                    else state <= IDLE;
                end
                FIWR: if(fd_fw) state <= WAIT;
                WAIT: state <= FIRD;
                FIRD: if(fd_fr) state <= LAST;
                LAST: state <= LAST;
                default: state <= LAST;
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
        .empty(fifo_empty),
        .wr_data_count(fifo_txnum),
        .rd_data_count(fifo_rxnum)
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
        .data_len(LEN),
        .state_fw(state_fw),
        .fifo_num_fw(fifo_num_fw),
        .judge_fw(judge_fw),
        .num_fw(num_fw)
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
        .state_fr(state_fr),
        .fs(fs_fr),
        .fd(fd_fr)
    );



endmodule