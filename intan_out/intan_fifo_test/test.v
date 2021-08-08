module top(
    input clk
);

    wire fs_read, fd_read;

    wire sysc, fifo_rxc, fifo_txc, ilac;

    wire [1:0] fifo_rxen;
    wire [15:0] fifo_rxd;
    wire fifo_full;

    reg [7:0] fifo_rxd0_d0, fifo_rxd0_d1;
    reg [7:0] fifo_rxd1_d0, fifo_rxd1_d1;

    reg [7:0] state, next_state;

    wire [7:0] so_ifw0, so_ifw1;

    localparam IDLE = 8'h01, FITX = 8'h02, LAST = 8'h10;
    localparam FIRXH = 8'h04, FIRXL = 8'h08;

    assign fifo_rxen = {(state == FIRXH), (state == FIRXL)};
    assign fs_read = (state == FITX);

    always @(posedge fifo_rxc) begin
        state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(~fifo_full) next_state <= FITX;
                else next_state <= IDLE;
            end
            FITX: begin
                if(fd_read) next_state <= FIRXH;
                else next_state <= FITX;
            end
            FIRXH: begin
                if(fifo_rxd1_d0 == fifo_rxd1_d1 && fifo_rxd[15:8] == fifo_rxd1_d0) next_state <= FIRXL;
                else next_state <= FIRXH;
            end
            FIRXL: begin
                if(fifo_rxd0_d0 == fifo_rxd0_d1 && fifo_rxd[7:0] == fifo_rxd0_d0) next_state <= LAST;
                else next_state <= FIRXL;
            end
            LAST: begin
                next_state <= IDLE;
            end
            default: next_state <= IDLE;
        endcase
    end

     always @(posedge fifo_rxc) begin
         if(state == FITX) begin
             fifo_rxd0_d0 <= 8'hE0;
             fifo_rxd0_d1 <= 8'hE1;
             fifo_rxd1_d0 <= 8'hEE;
             fifo_rxd1_d1 <= 8'hEF;
         end
         else if(state == FIRXH) begin
             fifo_rxd0_d0 <= fifo_rxd0_d0;
             fifo_rxd0_d1 <= fifo_rxd0_d1;
             fifo_rxd1_d0 <= fifo_rxd[15:8];
             fifo_rxd1_d1 <= fifo_rxd1_d0;
         end
         else if(state == FIRXL) begin
             fifo_rxd0_d0 <= fifo_rxd[7:0];
             fifo_rxd0_d1 <= fifo_rxd0_d0;
             fifo_rxd1_d0 <= fifo_rxd1_d0;
             fifo_rxd1_d1 <= fifo_rxd1_d1;
         end
         else begin
             fifo_rxd0_d0 <= fifo_rxd0_d0;
             fifo_rxd0_d1 <= fifo_rxd0_d1;
             fifo_rxd1_d0 <= fifo_rxd1_d0;
             fifo_rxd1_d1 <= fifo_rxd1_d1;
         end
     end

    intan
    intan_dut(
        .rst(),
        .err(),
        .dev_kind(2'b11),
        
        .fs_check(),
        .fs_conf(),
        .fs_read(fs_read),
        .fd_check(),
        .fd_conf(),

        .so_fw0(so_ifw0),
        .so_fw1(so_ifw1),
        .fd_read(fd_read),

        .fifoi_txc(fifo_txc),
        .fifoi_rxc(fifo_rxc),
        .fifoi_rxen(fifo_rxen),
        .intan_id(32'hF0_F1_F2_F3),
        .fifoi_rxd(fifo_rxd),
        .fifoi_full(fifo_full)
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
        .probe4(so_ifw1)
    );




endmodule