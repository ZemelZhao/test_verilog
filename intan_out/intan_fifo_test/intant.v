module intan(
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

    wire fd_fw0, fd_fw1;
    wire fifoi_full0, fifoi_full1;
    wire fifoi_txen0, fifoi_txen1;
    wire fifoi_empty1, fifoi_empty0;

    wire [7:0] fifoi_txd0, fifoi_txd1;
    reg [11:0] fifoi_len0, fifoi_len1;


    assign fifoi_full = {fifoi_full1, fifoi_full0};
    assign fifoi_empty = {fifoi_empty1, fifoi_empty0};


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

    
    assign fd_read = fd_fw0 && fd_fw1;


    fifo_write 
    fifo_write_dut1(
        .clk(fifoi_txc),
        .rst(),
        .err(),
        .fifo_txd(fifoi_txd1),
        .fifo_txen(fifoi_txen1),
        .fs(fs_read),
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
        .fs(fs_read),
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