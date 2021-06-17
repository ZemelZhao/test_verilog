module asm(
);
    wire clk, rst_n;
    wire fifo_empty, fifo_full;
    wire rst;


    assign rst = ~rst_n;
    wire [7:0] fifo_txd;
    wire [7:0] fifo_rxd;
    wire fifo_txen, fifo_rxen;

    reg [3:0] state;
    reg [7:0] num;
    localparam MAX = 8'h0F;
    localparam IDLE = 4'h0, PRET = 4'h1, TXEN = 4'h2;
    localparam PRER = 4'h3, RXEN = 4'h4, DONE = 4'h5;
    assign fifo_txd = num + 8'h40;
    assign fifo_txen = (state == TXEN);
    assign fifo_rxen = (state == RXEN);


    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else begin
            case(state)
                IDLE: begin
                    if(fifo_full == 1'b0) state <= PRET;
                    else state <= IDLE;
                end
                PRET: begin
                    state <= TXEN;
                    num <= 8'h00;
                end
                TXEN: begin
                    num <= num + 1'b1;
                    if(num == MAX) state <= PRER;
                    else state <= TXEN;
                end
                PRER: begin
                    num <= 8'h00;
                    state <= RXEN;
                end
                RXEN: begin
                    num <= num + 1'b1;
                    if(num == (MAX + 1'b1)) state <= DONE;
                    else state <= RXEN;
                end
                DONE: begin
                    state <= DONE;
                end
            endcase
        end
    end





    fifod
    fifod_dut(
        .wr_clk(clk),
        .wr_en(fifo_txen),
        .din(fifo_txd),

        .rd_clk(clk),
        .rd_en(fifo_rxen),
        .dout(fifo_rxd),

        .rst(rst),
        .full(fifo_full),
        .empty(fifo_empty)

    );

    clk_asm
    clk_asm_dut(
        .axi_clk_0(clk),
        .axi_rst_0_n(rst_n)
    );




endmodule