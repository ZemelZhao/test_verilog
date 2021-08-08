module intan(
    input clk,
    input rst,
    output err,

    input [1:0] dev_kind,

    input fs_check,
    input fs_conf,
    input fs_read,
    output fd_check,
    output fd_conf,
    output fd_read,

    input fifoi_txc,

    input fifoi_rxc,
    input [1:0] fifoi_rxen,
    input [31:0] intan_id,
    output [15:0] fifoi_rxd,
    output [1:0] fifoi_full,
    output [1:0] fifoi_empty,
    output [7:0] so_fw0, 
    output [7:0] so_fw1

);

    localparam IDLE = 8'h11; 
    localparam WFCK = 8'h21, FDCK = 8'h12; 
    localparam WFCF = 8'h41, FDCF = 8'h22;
    localparam WFRD = 8'h81, FSRD = 8'h82, FDRD = 8'h84;

    wire fd_fw0, fd_fw1;
    wire fifoi_full0, fifoi_full1;
    wire fifoi_txen0, fifoi_txen1;
    wire fifoi_empty1, fifoi_empty0;

    wire [7:0] fifoi_txd0, fifoi_txd1;
    reg [11:0] fifoi_len0, fifoi_len1;

    reg [7:0] state, next_state;
    wire fs_read_fifo, fd_read_fifo;

    assign fifoi_full = {fifoi_full1, fifoi_full0};
    assign fifoi_empty = {fifoi_empty1, fifoi_empty0};
    assign fd_check = (state == FDCK);
    assign fd_conf = (state == FDCF);
    assign fd_read_fifo = fd_fw0 && fd_fw1;
    assign fs_read_fifo = (state == FSRD);
    assign fd_read = (state == FDRD);

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                next_state <= WFCK;
            end
            WFCK: begin
                if(fs_check) next_state <= FDCK;
                else next_state <= WFCK;
            end
            FDCK: begin
                if(~fs_check) next_state <= WFCF;
                else next_state <= FDCK;
            end
            WFCF: begin
                if(fs_conf) next_state <= FDCF;
                else next_state <= WFCF;
            end
            FDCF: begin
                if(~fs_conf) next_state <= WFRD;
                else next_state <= FDCF;
            end
            WFRD: begin
                if(fs_read) next_state <= FSRD;
                else next_state <= WFRD;
            end
            FSRD: begin
                if(fd_read_fifo) next_state <= FDRD;
                else next_state <= FSRD;
            end
            FDRD: begin
                if(~fs_read) next_state <= WFRD;
                else next_state <= FDRD;
            end
            default: next_state <= IDLE;
        endcase
    end


    always @(*) begin
        case(dev_kind)
            2'b00: begin
                fifoi_len1 <= 12'h00;
                fifoi_len0 <= 12'h00;
            end
            2'b01: begin
                fifoi_len1 <= 12'h20;
                fifoi_len0 <= 12'h00;
            end
            2'b10: begin
                fifoi_len1 <= 12'h40;
                fifoi_len0 <= 12'h00;
            end
            2'b11: begin
                fifoi_len1 <= 12'h40;
                fifoi_len0 <= 12'h40;
            end
            default: begin
                fifoi_len1 <= 12'h0;
                fifoi_len0 <= 12'h0;   
            end
        endcase
    end

    fifo_write 
    fifo_write_dut1(
        .clk(fifoi_txc),
        .rst(),
        .err(),
        .fifo_txd(fifoi_txd1),
        .fifo_txen(fifoi_txen1),
        .fs(fs_read_fifo),
        .fd(fd_fw1),
        .data_len(fifoi_len1),
        .fifo_full(),
        .part(intan_id[31:16]),
        .so(so_fw1)
    );

    fifo_write 
    fifo_write_dut0(
        .clk(fifoi_txc),
        .rst(),
        .err(),
        .fifo_txd(fifoi_txd0),
        .fifo_txen(fifoi_txen0),
        .fs(fs_read_fifo),
        .fd(fd_fw0),
        .data_len(fifoi_len0),
        .fifo_full(),
        .part(intan_id[15:0]),
        .so(so_fw0)
    );


    
    fifoi
    fifoi_dut1(
        .rst(),

        .wr_clk(fifoi_txc),
        .din(fifoi_txd1),
        .wr_en(fifoi_txen1),

        .rd_clk(fifoi_rxc),
        .dout(fifoi_rxd[15:8]),
        .rd_en(fifoi_rxen[1]),

        .full(fifoi_full1),
        .empty(fifoi_empty1)
    );

    fifoi
    fifoi_dut0(
        .rst(),

        .wr_clk(fifoi_txc),
        .din(fifoi_txd1),
        .wr_en(fifoi_txen1),

        .rd_clk(fifoi_rxc),
        .dout(fifoi_rxd[7:0]),
        .rd_en(fifoi_rxen[0]),

        .full(fifoi_full0),
        .empty(fifoi_empty0)
    );




endmodule