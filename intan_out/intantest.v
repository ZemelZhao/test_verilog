module intan (
    // #### 1. CRE SECTION
    input clk,
    input rst,
    output err,

    input spi_mc,

    // #### 2. CONTROL SECTION
    // ###### 1. INTAN CONTROL PART
    output reg [1:0] dev_kind, // 00: None; 01: 2116; 10: 2132; 11: 2164,

    input fs_check,
    input fs_conf,
    input fs_read,
    output fd_check,
    output fd_conf,
    output fd_read,

    // ###### 2. FIFO CONTROL PART
    input [1:0] cache_fifoi_rxen,
    output [15:0] cache_fifoi_rxd

);



    reg [7:0] state;
    reg [7:0] next_state;

    wire [15:0] fifoi_txd;

    // FIFO CONTROL
    reg fifoi_txen;
    reg fs_fifo;
    wire fd_fifo;
    // FIFO DATA
    // ERROR




    fifoi
    fifoi_dut0(
        .rst(rst),
        .wr_clk(fifoc_txc0),
        .din(fifoi_txd[15:8]),
        .wr_en(fifoi_txen),
        .rd_clk(fifoi_rxc),
        .dout(cache_fifoi_rxd[15:8]),
        .rd_en(cache_fifoi_rxen[1])
    );

    fifoi
    fifoi_dut0(
        .rst(rst),
        .wr_clk(fifoi_txc),
        .din(fifoi_txd[7:0]),
        .wr_en(fifoi_txen),
        .rd_clk(fifoi_rxc),
        .dout(cache_fifoi_rxd[7:0]),
        .rd_en(cache_fifoi_rxen[0])
    );
    
endmodule