module intan(
    input clk,
    input rst,
    output err,

    output reg [1:0] dev_kind,

    input fs_check,
    input fs_conf,
    input fs_read,
    output fd_check,
    output fd_conf,
    output fd_read,

    input fifoi_rxc,
    input [1:0] fifoi_rxen,
    input [31:0] intan_id,
    output [15:0] fifoi_rxd

);

    wire fd_fw0, fd_fw1;
    wire fifoi_full0, fifoi_full1;
    wire fifoi_txen0, fifoi_txen1;

    wire [7:0] fifoi_txd0, fifoi_txd1;
    reg [11:0] fifoi_len0, fifoi_len1;


    always @(*) begin
        case(dev_kind)
            2'b00: begin
                fifoi_len1 <= 12'h0;
                fifoi_len0 <= 12'h0;
            end
            2'b00: begin
                fifoi_len1 <= 12'h0;
                fifoi_len0 <= 12'h20;
            end
            2'b00: begin
                fifoi_len1 <= 12'h0;
                fifoi_len0 <= 12'h40;
            end
            2'b00: begin
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
    fifo_write_dut0(
        .clk(clk),
        .rst(),
        .err(),
        .fifo_txd(fifoi_txd0),
        .fifo_txen(fifoi_txen0),
        .fs(fs_read),
        .fd(fd_fw0),
        .data_len(fifoi_len0),
        .fifo_full(),
        .part(intan_id[31:16])
    );

    fifo_write 
    fifo_write_dut1(
        .clk(clk),
        .rst(),
        .err(),
        .fifo_txd(fifoi_txd1),
        .fifo_txen(fifoi_txen1),
        .fs(fs_read),
        .fd(fd_fw1),
        .data_len(fifoi_len1),
        .fifo_full(),
        .part(intan_id[15:0])
    );


    
    fifoi
    fifoi_dut0(
        .rst(),

        .wr_clk(clk),
        .din(fifoi_txd0),
        .wr_en(fifoi_txen0),

        .rd_clk(clk),
        .dout(fifoi_rxd0),
        .rd_en(fifoi_rxen),

        .full(fifoi_full0)
    );

    fifoi
    fifoi_dut1(
        .rst(),

        .wr_clk(clk),
        .din(fifoi_txd1),
        .wr_en(fifoi_txen1),

        .rd_clk(clk),
        .dout(fifoi_rxd1),
        .rd_en(fifoi_rxen),

        .full(fifoi_full1)
    );




endmodule