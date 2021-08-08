module top(
    input clk,
    output [3:0] led
);

    localparam VERSION = 4'h3;

    wire fs_read, fd_read;
    wire fs_check, fd_check;
    wire fs_conf, fd_conf;

    wire sysc, fifo_rxc, fifo_txc, ilac;

    wire [1:0] fifo_rxen;
    wire [15:0] fifo_rxd;
    wire [1:0] fifo_full;
    wire [1:0] fifo_empty;

    reg [7:0] state, next_state;

    wire [7:0] so_ifw0, so_ifw1;

    localparam IDLE = 8'h01, FITX = 8'h02, LAST = 8'h10;
    localparam FIRXH = 8'h04, FIRXL = 8'h08;
    localparam CHECK = 8'h20, CONF = 8'h40, PREP = 8'h80;

    assign fifo_rxen = {(state == FIRXH), (state == FIRXL)};
    assign fs_read = (state == FITX);
    assign led = ~VERSION;

    assign fs_check = (state == CHECK);
    assign fs_conf = (state == CONF);

    always @(posedge fifo_rxc) begin
        state <= next_state;
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
                if(fd_read) next_state <= FIRXH;
                else next_state <= FITX;
            end
            FIRXH: begin
                if(fifo_empty[1]) next_state <= FIRXL;
                else next_state <= FIRXH;
            end
            FIRXL: begin
                if(fifo_empty[0]) next_state <= LAST;
                else next_state <= FIRXL;
            end
            LAST: begin
                next_state <= PREP;
            end
            default: next_state <= IDLE;
        endcase
    end


    intan
    intan_dut(
        .clk(sysc),
        .rst(),
        .err(),
        .dev_kind(2'b11),
        
        .fs_check(fs_check),
        .fs_conf(fs_conf),
        .fs_read(fs_read),
        .fd_check(fd_check),
        .fd_conf(fd_conf),
        .fd_read(fd_read),

        .so_fw0(so_ifw0),
        .so_fw1(so_ifw1),

        .fifoi_txc(fifo_txc),
        .fifoi_rxc(fifo_rxc),
        .fifoi_rxen(fifo_rxen),
        .intan_id(32'hF0_F1_F2_F3),
        .fifoi_rxd(fifo_rxd),
        .fifoi_full(fifo_full),
        .fifoi_empty(fifo_empty)
    );

    clk_factory
    clk_factory(
        .cin(clk),
        .sysc(sysc),
        .fifo_rxc(fifo_rxc),
        .fifo_txc(fifo_txc),
        .ilac(ilac)
    );

    ilap
    ilap_dut(
        .clk(ilac),
        .probe0(state),
        .probe1(fifo_rxd),
        .probe2(fifo_rxen),
        .probe3(so_ifw0),
        .probe4(so_ifw1),
        .probe5(fifo_empty)
    );




endmodule