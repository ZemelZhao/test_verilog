module spi2fifo(
    input clk,
    input rst,
    output err,

    input fs0,
    input fs1,
    output fd,

    input fifoi_full0,
    input fifoi_full1,

    input [15:0] chip_rxd0,
    input [15:0] chip_rxd1,

    output reg [1:0] fifoi_txen,
    output reg [15:0] fifoi_txd
);

    (* MARK_DEBUG="true" *)reg [7:0] state;
    reg [7:0] next_state;
    wire fs;
    wire fifoi_full;

    localparam IDLE = 8'h00, DAT0 = 8'h01, DAT1 = 8'h02, LAST = 8'h03;
    localparam WORK = 8'h04;

    assign fs = fs0 || fs1;
    assign fd = (state == LAST);
    assign fifoi_full = fifoi_full0 || fifoi_full1;

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(~fifoi_full) next_state <= WORK;
                else next_state <= IDLE;
            end
            WORK: begin
                if(fs) next_state <= DAT0;
                else next_state <= WORK;
            end
            DAT0: next_state <= DAT1;
            DAT1: next_state <= LAST;
            LAST: begin
                if(~fs) next_state <= IDLE;
                else next_state <= LAST;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            fifoi_txd <= 16'h0000;
            fifoi_txen <= 2'h0;
        end
        else if(state == DAT0) begin
            fifoi_txd <= {chip_rxd1[15:8], chip_rxd0[15:8]};
            fifoi_txen <= {fs1, fs0};
        end
        else if(state == DAT1) begin
            fifoi_txd <= {chip_rxd1[7:0], chip_rxd0[7:0]};
            fifoi_txen <= {fs1, fs0};
        end
        else begin
            fifoi_txd <= 16'h0000;
            fifoi_txen <= 2'h0;
        end
    end

endmodule