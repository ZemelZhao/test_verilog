module cs(
    // CLK
    input osc_clk,
    input eth_clk,
    output sys_clk,
    output fifo_clk,
    output gmii_rxc,
    output gmii_txc,
    output spi_mclk,

    // RST
    input sys_rst,
    output all_rst,
    output run_rst,

    // ERR

    // ADC REG
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
    output [7:0] adc_regap,

    // FIFO
    input fifoc_full,
    input fifod_full,
    input fifoa_full,

    // FLAG
    input fs_udp_rx,
    output fs_udp_tx,
    output fs_fifod2mac,
    output fs_mac2fifoc,
    output fs_fifoc2cs,
    output fs_adc_check,
    output fs_adc_conf,
    output fs_adc_read,
    output fs_adc_fifo,

    output fd_udp_rx,
    input fd_udp_tx,
    input fd_fifod2mac,
    input fd_mac2fifoc,
    input fd_fifoc2cs,
    input fd_adc_check,
    input fd_adc_conf,
    input fd_adc_read,
    input fd_adc_fifo,

    // NUM
    input [7:0] info_sr,
    input [7:0] kind_dev,

    output [9:0] adc_rx_len,
    output [11:0] eth_tx_len,

    output [63:0] intan_cmd, 
    output [63:0] intan_ind,
    output [7:0] intan_lor,
    output [7:0] intan_end

);

    // RUN PARAMETER

    wire [3:0] dev_id;
    wire [3:0] dat_id;
    wire dev_grp;
    wire [7:0] adc_cnt;

    // CLOCK
    wire adc_rxc;
    wire fs_adc;


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
        .cmd_kdev(kind_dev),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .data_cnt(adc_cnt),
        .intan_cmd(intan_cmd),
        .intan_ind(intan_ind),
        .intan_lor(intan_lor),
        .intan_end(intan_end)
    );

    cs_com
    cs_com_dut(
        .sys_clk(sys_clk),
        .rst(run_rst),
        .adc_rxc(adc_rxc),
        .com0(dev_com[3:2]),
        .com1(dev_com[1:0]),
        .fd_adc_conf(fd_adc_conf),
        .dev_grp(dev_grp),
        .fs_adc(fs_adc),
        .dat_id(dat_id)
    );


    



endmodule