module adc(
    input sys_clk,
    input fifoa_txc,
    input fifoa_rxc,
    input rst,
    input spi_mc,

    output adc_rxen,
    output [7:0] adc_rxd,

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

    output fifoa_full,
    output fifoa_empty,

    input [63:0] adc_cmd,
    input [63:0] adc_ind,
    input [7:0] adc_lor,
    input [7:0] adc_end,
    
    output [7:0] sos,
    output [7:0] sos0,
    output [63:0] sol
);
    wire [3:0] fd_gck;
    wire [3:0] fs_gcf, fd_gcf;
    wire [3:0] fs_grd, fd_grd;
    wire [63:0] fifoi_grxd;
    wire [7:0] fifoi_grxen, fifoi_gfull, fifoi_gempty;

    wire [3:0] intan_gnull;

    assign intan_gnull[3] = ~|dev_kind[7:6];
    assign intan_gnull[2] = ~|dev_kind[5:4];
    assign intan_gnull[1] = ~|dev_kind[3:2];
    assign intan_gnull[0] = ~|dev_kind[1:0];

    assign fs_gcf = {4{fs_conf}} & (~intan_gnull);
    assign fs_grd = {4{fs_read}} & (~intan_gnull);

    assign fd_conf = &(intan_gnull | fd_gcf);
    assign fd_read = &(intan_gnull | fd_grd);
    assign fd_check = &fd_gck;

    assign fifoa_full = |fifoi_gfull;
    assign fifoa_empty = &fifoi_gempty;

    fifo2adc
    fifo2adc_dut(
        .clk(fifoa_rxc),
        .rst(),
        .err(),

        .fs_fifo(fs_fifo),
        .fd_fifo(fd_fifo),

        .adc_rxen(adc_rxen),
        .fifoi_grxen(fifoi_grxen),
        
        .dev_kind(dev_kind),
        .dev_info(dev_info),
        .dev_smpr(dev_smpr),

        .fifoi_grxd(fifoi_grxd),
        .adc_rxd(adc_rxd),

        .intan_cmd(adc_cmd),
        .intan_ind(adc_ind),
        .intan_lor(adc_lor),
        .intan_end(adc_end),
        .sos(sos),
        .sos0(sos0),
        .sol(sol)

    );

    intan
    intan_dut0(
        .clk(sys_clk),
        .fifoi_txc(fifoa_txc),
        .fifoi_rxc(fifoa_rxc),
        .rst(),
        .err(),

        .dev_kind(dev_kind[7:6]),
        .intan_id(32'hF0_F1_F2_F3),

        .fs_check(fs_check),
        .fs_conf(fs_gcf[3]),
        .fs_read(fs_grd[3]),
        .fd_check(fd_gck[3]),
        .fd_conf(fd_gcf[3]),
        .fd_read(fd_grd[3]),

        .fifoi_rxen(fifoi_grxen[7:6]),
        .fifoi_rxd(fifoi_grxd[63:48]),
        
        .fifoi_full(fifoi_gfull[7:6]),
        .fifoi_empty(fifoi_gempty[7:6])
    );

    intan
    intan_dut1(
        .clk(sys_clk),
        .fifoi_txc(fifoa_txc),
        .fifoi_rxc(fifoa_rxc),
        .rst(),
        .err(),

        .dev_kind(dev_kind[5:4]),
        .intan_id(32'hF4_F5_F6_F7),

        .fs_check(fs_check),
        .fs_conf(fs_gcf[2]),
        .fs_read(fs_grd[2]),
        .fd_check(fd_gck[2]),
        .fd_conf(fd_gcf[2]),
        .fd_read(fd_grd[2]),

        .fifoi_rxen(fifoi_grxen[5:4]),
        .fifoi_rxd(fifoi_grxd[47:32]),
        
        .fifoi_full(fifoi_gfull[5:4]),
        .fifoi_empty(fifoi_gempty[5:4])
    );

    intan
    intan_dut2(
        .clk(sys_clk),
        .fifoi_txc(fifoa_txc),
        .fifoi_rxc(fifoa_rxc),
        .rst(),
        .err(),

        .dev_kind(dev_kind[3:2]),
        .intan_id(32'hF8_F9_FA_FB),

        .fs_check(fs_check),
        .fs_conf(fs_gcf[1]),
        .fs_read(fs_grd[1]),
        .fd_check(fd_gck[1]),
        .fd_conf(fd_gcf[1]),
        .fd_read(fd_grd[1]),

        .fifoi_rxen(fifoi_grxen[3:2]),
        .fifoi_rxd(fifoi_grxd[31:16]),
        
        .fifoi_full(fifoi_gfull[3:2]),
        .fifoi_empty(fifoi_gempty[3:2])
    );

    intan
    intan_dut3(
        .clk(sys_clk),
        .fifoi_txc(fifoa_txc),
        .fifoi_rxc(fifoa_rxc),
        .rst(),
        .err(),

        .dev_kind(dev_kind[1:0]),
        .intan_id(32'hFC_FD_FE_FF),

        .fs_check(fs_check),
        .fs_conf(fs_gcf[0]),
        .fs_read(fs_grd[0]),
        .fd_check(fd_gck[0]),
        .fd_conf(fd_gcf[0]),
        .fd_read(fd_grd[0]),

        .fifoi_rxen(fifoi_grxen[1:0]),
        .fifoi_rxd(fifoi_grxd[15:0]),
        
        .fifoi_full(fifoi_gfull[1:0]),
        .fifoi_empty(fifoi_gempty[1:0])
    );


endmodule