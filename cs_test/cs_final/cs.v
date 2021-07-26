module cs(
    // CLK
    input osc_clk,
    input net_clk,

    output sys_clk,
    output eth_clk,

    output dev_grp,
    output [3:0] dev_id,

    input fifoa_full,
    input fifoc_full,
    input fifod_full,

    input fs_udp_rx,
    input fd_mac2fifoc,
    input fd_fifoc2cs,

    output fd_udp_rx,
    output fs_mac2fifoc,
    output fs_fifoc2cs,

    output [9:0] adc_rx_len,
    output [11:0] eth_tx_len,

    input err_fifoc2cs,

    input [7:0] kind_dev,
    input [7:0] info_sr,
    input [7:0] cmd_filt,
    input [7:0] cmd_mix0,
    input [7:0] cmd_mix1,
    input [7:0] cmd_reg4,
    input [7:0] cmd_reg5,
    input [7:0] cmd_reg6,
    input [7:0] cmd_reg7,

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
    output [7:0] adc_regap

);

    wire fs_cs_num, fd_cs_num;


    cs_clk
    cs_clk_dut(
        .osc_clk(osc_clk),
        .net_clk(net_clk),

        .sys_clk(sys_clk),
        .eth_clk(eth_clk)
    );

    cs_cmd
    cs_cmd_dut(
        .clk(sys_clk),
        .rst(),
        
        .fifoa_full(fifoa_full),
        .fifoc_full(fifoc_full),
        .fifod_full(fifod_full),

        .fd_udp_rx(fd_udp_rx),
        .fs_mac2fifoc(fs_mac2fifoc),
        .fs_fifoc2cs(fs_fifoc2cs),
        .fs_cs_num(fs_cs_num),

        .fs_udp_rx(fs_udp_rx),
        .fd_mac2fifoc(fd_mac2fifoc),
        .fd_fifoc2cs(fd_fifoc2cs),
        .fd_cs_num(fd_cs_num),

        .err_fifoc2cs(err_fifoc2cs)
    );

    cs_reg
    cs_reg_dut(
        .cmd_filt(cmd_filt),
        .cmd_mix0(cmd_mix0),
        .cmd_mix1(cmd_mix1),
        .cmd_reg4(cmd_reg4),
        .cmd_reg5(cmd_reg5),
        .cmd_reg6(cmd_reg6),
        .cmd_reg7(cmd_reg7),
        
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
        .clk(sys_clk),
        .rst(),
        .cmd_kdev(kind_dev),

        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),

        .fs(fs_cs_num),
        .fd(fd_cs_num)
    );


endmodule