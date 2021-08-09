module adc(
    input sysc,
    input fifoi_txc,
    input fifoi_rxc,
    input fifod_txc,
    input rst,
    input spi_mc,

    output fifod_txen,
    output [7:0] fifod_txd,

    input fs_check,
    input fs_conf,
    input fs_read,
    input fs_fifo,
    output fd_check,
    output fd_conf,
    output fd_read,
    output fd_fifo,

    input [7:0] dev_smpr,
    input [7:0] dev_info,
    input [7:0] dev_kind,

    input [63:0] adc_cmd,
    input [63:0] adc_ind,
    input [7:0] adc_lor,
    input [7:0] adc_end
);

    wire sysc, fifoi_txc, fifod_txc, fifod_rxc;

    wire [7:0] dev_kind;

    wire [3:0] fs_check, fd_check, fd_ocheck;
    wire [3:0] fs_conf, fd_conf, fd_oconf;
    wire [3:0] fs_read, fd_read, fd_oread;
    wire [63:0] fifoi_txd;
    wire [7:0] fifoi_rxen, fifoi_full, fifoi_empty;

    fifo2adc
    fifo2adc_dut(
        .clk(sysc),
        .rst(),
        .err(),

    );

    intan
    intan_dut0(
        .clk(sysc),
        .fifoi_txc(fifoi_txc),
        .fifoi_rxc(fifod_txc),
        .rst(),
        .err(),

        .dev_kind(dev_kind[7:6]),
        .intan_id(32'hF0_F1_F2_F3),

        .fs_check(fs_check[3]),
        .fs_conf(fs_conf[3]),
        .fs_read(fs_read[3]),
        .fd_check(fd_ocheck[3]),
        .fd_conf(fd_oconf[3]),
        .fd_read(fd_oread[3]),

        .fifoi_rxen(fifoi_rxen[7:6]),
        .fifoi_rxd(fifoi_txd[63:48]),
        
        .fifoi_full(fifoi_full[7:6]),
        .fifoi_empty(fifoi_empty[7:6])
    );

    intan
    intan_dut1(
        .clk(sysc),
        .fifoi_txc(fifoi_txc),
        .fifoi_rxc(fifod_txc),
        .rst(),
        .err(),

        .dev_kind(dev_kind[5:4]),
        .intan_id(32'hF4_F5_F6_F7),

        .fs_check(fs_check[2]),
        .fs_conf(fs_conf[2]),
        .fs_read(fs_read[2]),
        .fd_check(fd_ocheck[2]),
        .fd_conf(fd_oconf[2]),
        .fd_read(fd_oread[2]),

        .fifoi_rxen(fifoi_rxen[5:4]),
        .fifoi_rxd(fifoi_txd[47:32]),
        
        .fifoi_full(fifoi_full[5:4]),
        .fifoi_empty(fifoi_empty[5:4])
    );

    intan
    intan_dut2(
        .clk(sysc),
        .fifoi_txc(fifoi_txc),
        .fifoi_rxc(fifod_txc),
        .rst(),
        .err(),

        .dev_kind(dev_kind[3:2]),
        .intan_id(32'hF8_F9_FA_FB),

        .fs_check(fs_check[1]),
        .fs_conf(fs_conf[1]),
        .fs_read(fs_read[1]),
        .fd_check(fd_ocheck[1]),
        .fd_conf(fd_oconf[1]),
        .fd_read(fd_oread[1]),

        .fifoi_rxen(fifoi_rxen[3:2]),
        .fifoi_rxd(fifoi_txd[31:15]),
        
        .fifoi_full(fifoi_full[3:2]),
        .fifoi_empty(fifoi_empty[3:2])
    );

    intan
    intan_dut3(
        .clk(sysc),
        .fifoi_txc(fifoi_txc),
        .fifoi_rxc(fifod_txc),
        .rst(),
        .err(),

        .dev_kind(dev_kind[1:0]),
        .intan_id(32'hFC_FD_FE_FF),

        .fs_check(fs_check[0]),
        .fs_conf(fs_conf[0]),
        .fs_read(fs_read[0]),
        .fd_check(fd_ocheck[0]),
        .fd_conf(fd_oconf[0]),
        .fd_read(fd_oread[0]),

        .fifoi_rxen(fifoi_rxen[1:0]),
        .fifoi_rxd(fifoi_txd[15:0]),
        
        .fifoi_full(fifoi_full[1:0]),
        .fifoi_empty(fifoi_empty[1:0])
    );


endmodule