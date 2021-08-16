module test(
    input clk,
    input fclk,
    input rst_n,
    output [7:0] show_state,
    output [7:0] show_adc_rxd,
    output [7:0] show_fifod_rxd,
    output [7:0] sos,
    output [7:0] sos0,
    output [63:0] sol
);

    wire sys_clk, fifo_clk;
    wire rst;

    wire fifod_txc, fifod_rxc;
    wire fifoc_txc, fifoc_rxc;
    wire fifoa_txc, fifoa_rxc;

    wire fifod_txen, fifod_rxen;
    wire fifoc_txen, fifoc_rxen;

    wire [7:0] fifod_txd, fifod_rxd;
    wire [7:0] fifoc_txd, fifoc_rxd;

    wire fifo_full, fifo_empty;
    wire fifod_full, fifoc_full, fifoa_full;
    wire fifod_empty, fifoc_empty, fifoa_empty;

    wire fs_check, fd_check;
    wire fs_conf, fd_conf;
    wire fs_read, fd_read;
    wire fs_fifo, fd_fifo;
    wire fs_dtrx, fd_dtrx;

    wire [7:0] dev_smpr, dev_info, dev_kind;
    wire [63:0] adc_cmd, adc_ind;
    wire [7:0] adc_lor, adc_end;

    wire [9:0] adc_rx_len;
    wire [11:0] eth_tx_len;
    wire [7:0] adc_cnt;

    wire adc_rxen;
    wire [7:0] adc_rxd;

    reg [7:0] state, next_state;
    reg [7:0] adc_num;

    localparam IDLE = 8'h00, CHECK = 8'h01, CONF = 8'h02, PREP = 8'h03;
    localparam FITX = 8'h04, FIRX = 8'h05, CONT = 8'h06, DTRX = 8'h07;
    localparam LAST = 8'h08;

    assign fifo_full = {fifoa_full, fifoc_full, fifod_full};
    assign show_state = state;
    assign show_adc_rxd = adc_rxd;
    assign show_fifod_rxd = fifod_rxd;

    assign dev_kind = 8'hF5;
    assign dev_smpr = 8'hFA;
    assign dev_info = 8'hC9;

    assign sys_clk = clk;
    assign fifo_clk = fclk;

    assign fifoa_rxc = fifo_clk;
    assign fifoa_txc = fifo_clk;
    assign fifoc_rxc = fifo_clk;
    assign fifoc_txc = fifo_clk;
    assign fifod_rxc = fifo_clk;
    assign fifod_txc = fifo_clk;

    assign rst = ~rst_n;
    assign fs_check = (state == CHECK);
    assign fs_conf = (state == CONF);
    assign fs_read = (state == FITX);
    assign fs_fifo = (state == FIRX);
    assign fs_dtrx = (state == DTRX);

    // assign sos = adc_num;


    always @(posedge sys_clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                next_state <= CHECK;
            end
            CHECK: begin
                if(fd_check) next_state <= CONF;
                else next_state <= CHECK;
            end
            CONF: begin
                if(fd_conf) next_state <= PREP;
                else next_state <= CONF;
            end
            PREP: begin
                if(~|fifo_full) next_state <= FITX;
                else next_state <= PREP;
            end
            FITX: begin
                if(fd_read) next_state <= FIRX;
                else next_state <= FITX;
            end
            FIRX: begin
                if(fd_fifo) next_state <= CONT;
                else next_state <= FIRX;
            end
            CONT: begin
                if(adc_num < adc_cnt - 1'b1) next_state <= LAST;
                else next_state <= DTRX;
            end
            DTRX: begin
                if(fd_dtrx) next_state <= LAST;
                else next_state <= DTRX;
            end
            LAST: begin
                next_state <= PREP;
            end
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge sys_clk or posedge rst) begin
        if(rst) adc_num <= 8'h0;
        else if(state == CONT) adc_num <= adc_num + 1'b1;
        else if(state == DTRX) adc_num <= 8'h0;
        else adc_num <= adc_num;
    end



    adc
    adc_dut(
        .sys_clk(sys_clk),
        .fifoa_txc(fifoa_txc),
        .fifoa_rxc(fifoa_rxc),

        .rst(),
        .spi_mc(),

        .adc_rxen(adc_rxen),
        .adc_rxd(adc_rxd),

        .fs_check(fs_check),
        .fd_check(fd_check),
        .fs_conf(fs_conf),
        .fd_conf(fd_conf),
        .fs_read(fs_read),
        .fd_read(fd_read),
        .fs_fifo(fs_fifo),
        .fd_fifo(fd_fifo),

        .dev_smpr(dev_smpr),
        .dev_info(dev_info),
        .dev_kind(dev_kind),

        .fifoa_full(fifoa_full),
        .fifoa_empty(fifoa_empty),

        .adc_cmd(adc_cmd),
        .adc_ind(adc_ind),
        .adc_lor(adc_lor),
        .adc_end(adc_end),
        .sos0(sos0),
        .sos(sos),
        .sol(sol)
    );

    cs
    cs_dut(
        .osc_clk(sys_clk),
        .sys_clk(),
        .fifo_clk(),

        .kind_dev(dev_kind),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .adc_cnt(adc_cnt),

        .intan_cmd(adc_cmd),
        .intan_ind(adc_ind),
        .intan_lor(adc_lor),
        .intan_end(adc_end)
    );

    adc2fifod
    adc2fifod_dut(
        .fifod_txd(fifod_txd),
        .fifod_txen(fifod_txen),
        .adc_rxen(adc_rxen),
        .adc_rxd(adc_rxd)
    );

    fifo_read
    fifo_read_dut(
        .clk(fifod_rxc),
        .rst(),
        .err(),
        .data_len(eth_tx_len),
        .fifo_rxd(fifod_rxd),
        .fifo_rxen(fifod_rxen),
        .fs(fs_dtrx),
        .fd(fd_dtrx)
    );

    fifod
    fifod_dut(
        .rst(),

        .wr_clk(fifod_txc),
        .din(fifod_txd),
        .wr_en(fifod_txen),

        .rd_clk(fifod_rxc),
        .dout(fifod_rxd),
        .rd_en(fifod_rxen),

        .full(fifod_full),
        .empty(fifod_empty)
    );


    fifoc
    fifoc_dut(
        .rst(),

        .wr_clk(fifoc_txc),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),

        .rd_clk(fifoc_rxc),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen),

        .full(fifoc_full),
        .empty(fifoc_empty)
    );
    

endmodule