
module cs(
    // CRE SECTION
    input clk,
    input rst,

    // CLK SECNTION
    output spi_mc,

    //  ADC CMD
    input fs_adc_ext,
    input [3:0] dev_num_ext,
    output [7:0] dev_info,
    output [7:0] dev_kind,
    output [7:0] dev_smpr,

    // DATA_LEN
    input [11:0] eth_rx_len,
    output [11:0] eth_tx_len,
    output [9:0] adc_rx_len,

    // CMD
    input [7:0] cmd_kdev,
    input [7:0] cmd_smpr,
    input [7:0] cmd_filt,
    input [7:0] cmd_mix0,
    input [7:0] cmd_mix1,
    input [7:0] cmd_reg4,
    input [7:0] cmd_reg5,
    input [7:0] cmd_reg6,
    input [7:0] cmd_reg7,

    // REG
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

    // RESET
    output rst_mac,
    output rst_adc,
    output rst_fifod,
    output rst_fifoc,
    output rst_eth2mac,
    output rst_fifod2mac,
    output rst_mac2fifoc,
    output rst_adc2fifod,
    output rst_fifoc2cs
);
    wire rst_cs_cmd;
    wire dev_grp;

    wire rst_all;
    wire rst_dev;
    wire [7:0] fifo2mac_num;

    wire fs_cs_num;
    wire fd_cs_num;
    wire fs_adc;
    wire fs_adc_int;

    assign fs_adc = (dev_grp) ?fs_adc_ext :fs_adc_int;
// NODE
    cs_cmd 
    cs_cmd_dut (
        .clk(clk),
        .rst(rst),
        .err(),

        .fs_adc(fs_adc),
        .fifo2mac_num(fifo2mac_num),
        .dev_grp(dev_grp),
        .dev_num_ext(dev_num_ext),

        .cmd_kdev(cmd_kdev),
        .cmd_smpr(cmd_smpr),
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

        .dev_info(dev_info),
        .dev_kind(dev_kind),
        .dev_smpr(dev_smpr),

        .rst_all(rst_all),
        .rst_dev(rst_dev),

        .fs_udp_rx(fs_udp_rx),
        .fs_udp_tx(fs_udp_tx),
        .fs_mac2fifoc(fs_mac2fifoc),
        .fs_fifoc2cs(fs_fifoc2cs),
        .fs_adc_check(fs_adc_check),
        .fs_adc_conf(fs_adc_conf),
        .fs_adc_read(fs_adc_read),
        .fs_adc_fifo(fs_adc_fifo),
        .fs_cs_num(fs_cs_num),

        .fd_udp_rx(fd_udp_rx),
        .fd_udp_tx(fd_udp_tx),
        .fd_mac2fifoc(fd_mac2fifoc),
        .fd_fifoc2cs(fd_fifoc2cs),
        .fd_adc_check(fd_adc_check),
        .fd_adc_conf(fd_adc_conf),
        .fd_adc_read(fd_adc_read),
        .fd_adc_fifo(fd_adc_fifo),
        .fd_cs_num(fd_cs_num)
    );


    cs_rst 
    cs_rst_dut (
        .rst_all(rst_all),
        .rst_dev(rst_dev),
        .rst_mac(rst_mac),
        .rst_adc(rst_adc),
        .rst_fifod(rst_fifod),
        .rst_fifoc(rst_fifoc),
        .rst_eth2mac(rst_eth2mac),
        .rst_mac2fifoc(rst_mac2fifoc),
        .rst_fifoc2cs(rst_fifoc2cs),
        .rst_adc2fifod(rst_adc2fifod),
        .rst_fifod2mac(rst_fifod2mac)
    );

    cs_num
    cs_num_dut(
        .clk(clk),
        .rst(rst_all),

        .fs(fs_cs_num),
        .fd(fd_cs_num),
        
        .cmd_kdev(cmd_kdev),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .data_cnt(fifo2mac_num)
    );





endmodule