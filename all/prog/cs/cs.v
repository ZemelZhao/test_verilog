module cs(
    // CLK
    input osc_clk,
    input eth_clk,
    output sys_clk,
    output fifo_clk,
    output gmii_rxc,
    output gmii_txc,
    output spi_mclk,
    output fifoa_txc,
    output fifoa_rxc,
    output fifoc_txc,
    output fifoc_rxc,
    output fifod_txc,
    output fifod_rxc,

    // RST
    input rst_sys,
    output rst_mac,
    output rst_adc,
    output rst_fifoc,
    output rst_fifod,
    output rst_mac2fifoc,
    output rst_fifoc2cs,
    output rst_adc2fifod,
    output rst_fifod2mac,

    // TEST
    input adc_rxc,
    input [3:0] dev_com,

    // ERR

    // ETH CMD
    input [7:0] eth_cmd0,
    input [7:0] eth_cmd1,
    input [7:0] eth_cmd2,
    input [7:0] eth_cmd3,
    input [7:0] eth_cmd4,
    input [7:0] eth_cmd5,
    input [7:0] eth_cmd6,
    input [7:0] eth_cmd7,
    input [7:0] eth_cmd8,

    output [7:0] adc_reg00,
    output [7:0] adc_reg01,
    output [7:0] adc_reg02,
    output [7:0] adc_reg03,
    output [7:0] adc_reg04,
    output [7:0] adc_reg05,    
    output [7:0] adc_reg06,
    output [7:0] adc_reg07,
    output [7:0] adc_reg08,
    output [7:0] adc_reg09,
    output [7:0] adc_reg10,
    output [7:0] adc_reg11,
    output [7:0] adc_reg12,
    output [7:0] adc_reg13,
    output [7:0] adc_regap,

    // FIFO
    input fifoc_full,
    input fifod_full,
    input fifoa_full,

    // FLAG
    input fs_udp_rx,
    output fs_mac2fifoc,
    output fs_fifoc2cs,
    output fd_udp_rx,
    input fd_mac2fifoc,
    input fd_fifoc2cs,

    output fs_udp_tx,
    output fs_fifod2mac,
    output fd_udp_tx,
    input fd_fifod2mac,

    output fs_adc_check,
    output fs_adc_conf,
    output fs_adc_read,
    output fs_adc_fifo,
    input fd_adc_check,
    input fd_adc_conf,
    input fd_adc_read,
    input fd_adc_fifo,

    // NUM
    output [7:0] dev_info,

    output [9:0] adc_rx_len,
    output [11:0] eth_tx_len,

    output [63:0] intan_cmd, 
    output [63:0] intan_ind,
    output [7:0] intan_lrt,
    output [7:0] intan_end
);

    // RUN PARAMETER

    wire [3:0] dev_id;
    wire [3:0] dat_id;
    wire dev_grp;
    wire [7:0] adc_cnt;

    // ADC_REG
    wire [7:0] kind_dev;
    wire [7:0] info_sr;
    wire [7:0] cmd_filt;
    wire [7:0] cmd_mix0, cmd_mix1, cmd_mix2;
    wire [7:0] cmd_zck0, cmd_zck1, cmd_zck2;

    // CLOCK
    wire fs_adc;

    // RST
    wire rst_all;
    wire rst_run;
    wire rst_cs_com;

    // 
    assign dev_info = {dev_id, dat_id};
    assign sys_clk = osc_clk;


    cs_reg 
    cs_reg_dut(
        .cmd_filt(cmd_filt),
        .cmd_mix0(cmd_mix0),
        .cmd_mix1(cmd_mix1),
        .cmd_mix2(cmd_mix2),
        .cmd_zck0(cmd_zck0),
        .cmd_zck1(cmd_zck1),
        .cmd_zck2(cmd_zck2),
        .reg00(adc_reg00),
        .reg01(adc_reg01),
        .reg02(adc_reg02),
        .reg03(adc_reg03),
        .reg04(adc_reg04),
        .reg05(adc_reg05),
        .reg06(adc_reg06),
        .reg07(adc_reg07),
        .reg08(adc_reg08),
        .reg09(adc_reg09),
        .reg10(adc_reg10),
        .reg11(adc_reg11),
        .reg12(adc_reg12),
        .reg13(adc_reg13),
        .regap(adc_regap),
        .dev_id(dev_id),
        .dev_grp(dev_grp)
    );

    cs_num 
    cs_num_dut(
        .cmd_kdev(kind_dev),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .data_cnt(adc_cnt),
        .intan_cmd(intan_cmd),
        .intan_ind(intan_ind),
        .intan_lrt(intan_lrt),
        .intan_end(intan_end)
    );

    cs_com
    cs_com_dut(
        .sys_clk(sys_clk),
        .rst(rst_cs_com),
        .adc_rxc(adc_rxc),
        .com0(dev_com[3:2]),
        .com1(dev_com[1:0]),
        .fd_adc_conf(fd_adc_conf),
        .dev_grp(dev_grp),
        .fs_adc(fs_adc),
        .dat_id(dat_id)
    );

    cs_cmd
    cs_cmd_dut(
        .sys_clk(sys_clk),
        .rst_sys(rst_sys),
        .rst_all(rst_all),
        .rst_run(rst_run),

        .fifoa_full(fifoa_full),
        .fifoc_full(fifoc_full),
        .fifod_full(fifod_full),

        .fs_adc(fs_adc),
        .adc_cnt(adc_cnt),

        .fs_udp_rx(fs_udp_rx),
        .fs_mac2fifoc(fs_mac2fifoc),
        .fs_fifoc2cs(fs_fifoc2cs),
        .fd_udp_rx(fd_udp_rx),
        .fd_mac2fifoc(fd_mac2fifoc),
        .fd_fifoc2cs(fd_fifoc2cs),

        .fs_udp_tx(fs_udp_tx),
        .fs_fifod2mac(fs_fifod2mac),
        .fd_udp_tx(fd_udp_tx),
        .fd_fifod2mac(fd_fifod2mac),

        .fs_adc_check(fs_adc_check),
        .fs_adc_conf(fs_adc_conf),
        .fs_adc_read(fs_adc_read),
        .fs_adc_fifo(fs_adc_fifo),
        .fd_adc_check(fd_adc_check),
        .fd_adc_conf(fd_adc_conf),
        .fd_adc_read(fd_adc_read),
        .fd_adc_fifo(fd_adc_fifo)
    );

    cs_rst
    cs_rst_dut(
        .rst_all(rst_all),
        .rst_run(rst_run),

        .rst_cs_com(rst_cs_com),
        .rst_mac(rst_mac),
        .rst_adc(rst_adc),
        .rst_fifoc(rst_fifoc),
        .rst_fifod(rst_fifod),
        .rst_mac2fifoc(rst_mac2fifoc),
        .rst_fifoc2cs(rst_fifoc2cs),
        .rst_adc2fifod(rst_adc2fifod),
        .rst_fifod2mac(rst_fifod2mac)
    );

    cs_ecmd 
    cs_ecmd_dut(
        .eth_cmd0(eth_cmd0),
        .eth_cmd1(eth_cmd1),
        .eth_cmd2(eth_cmd2),
        .eth_cmd3(eth_cmd3),
        .eth_cmd4(eth_cmd4),
        .eth_cmd5(eth_cmd5),
        .eth_cmd6(eth_cmd6),
        .eth_cmd7(eth_cmd7),
        .eth_cmd8(eth_cmd8),
        .dev_kind(kind_dev),
        .info_sr(info_sr),
        .cmd_filt(cmd_filt),
        .cmd_mix0(cmd_mix0),
        .cmd_mix1(cmd_mix1),
        .cmd_mix2(cmd_mix2),
        .cmd_zck0(cmd_zck0),
        .cmd_zck1(cmd_zck1),
        .cmd_zck2(cmd_zck2)
    );





endmodule