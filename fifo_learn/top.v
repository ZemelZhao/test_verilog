module top(
    input clk,
    input rst_n,

    output [31:0] led
);

    wire rst;
    wire fifo_full, fifo_empty;
    wire fifo_afull, fifo_aempty;
    wire fifo_txen, fifo_rxen;
    wire [7:0] fifo_txd, fifo_rxd;

    reg [3:0] state;

    assign rst = ~rst_n;
    assign led[31:8] = 24'h5A_A5_00;
    assign led[7] = ~fifo_txen;
    assign led[6] = clk;
    assign led[3] = ~fifo_full;
    assign led[2] = ~fifo_empty;
    assign led[1] = ~fifo_afull;
    assign led[0] = ~fifo_aempty;
    assign fifo_txen = (state < 4'h8);

    always@(posedge clk or posedge rst) begin
        if(rst) state <= 4'h0;
        else begin
            case(state) 
                4'h0: state <= 4'h1;
                4'h1: state <= 4'h2;
                4'h2: state <= 4'h3;
                4'h3: state <= 4'h4;
                4'h4: state <= 4'h5;
                4'h5: state <= 4'h6;
                4'h6: state <= 4'h7;
                4'h7: state <= 4'h8;
                4'h8: state <= 4'h8;
                default: state <= 4'h0;
            endcase
        end
    end

    fifod
    fifod_dut(
        .rst(rst),
        .wr_clk(clk),
        .full(fifo_full),
        .din(fifo_txd),
        .wr_en(fifo_txen),
        .prog_full(fifo_afull),

        .rd_clk(clk),
        .empty(fifo_empty),
        .dout(fifo_rxd),
        .rd_en(fifo_rxen),
        .prog_empty(fifo_aempty)
    );







endmodule