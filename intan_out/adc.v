// ## 0. DOCUMENT SECTION
// #region 
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//      Author: ZemZhao                                                         //
//      E-mail: zemzhao@163.com                                                 //
//      Please feel free to contact me if there are BUGs in my program.         //
//      For I know they are everywhere.                                         //
//      I can do nothing but encourage you to debug desperately.                //
//      GOOD LUCK, HAVE FUN!!                                                   //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                              SJTU BCI-Lab 205                                //
//                            All rights reserved                               //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
// adc.v:
// 该文件为 ADC-II 的主文件，

//////////////////////////////////////////////////////////////////////////////////
// #endregion 
module adc
(
    // ## 1. IO SECTION
    // #region
    input clk,
    input rst,
    input spi_mc,
    input fifoi_txc,
    input fifoi_rxc,

    // UP
    output fifod_txen,

    // CONTROL 
    input fs_check,
    output fd_check,
    input fs_conf,
    output fd_conf,
    input fs_read,
    output fd_read,
    input fs_fifo,
    output fd_fifo,
    output [7:0] fifod_txd,
    output [9:0] data_len,

    // INTAN
    input [7:0] dev_smpr,
    input [7:0] cache_dev_info,
    output [7:0] cache_dev_kind,

    // INTAN REG
    input [7:0] reg00,
    input [7:0] reg01,
    input [7:0] reg02,
    input [7:0] reg03,
    input [7:0] reg04,
    input [7:0] reg05,
    input [7:0] reg06,
    input [7:0] reg07,
    input [7:0] reg08,
    input [7:0] reg09,
    input [7:0] reg10,
    input [7:0] reg11,
    input [7:0] reg12,
    input [7:0] reg13,
    input [7:0] regap,

    // INTAN PIN
    input [3:0] cache_miso,
    output [3:0] cache_mosi,
    output [3:0] cache_cs,
    output [3:0] cache_sclk
    // #endregion
);
    // ## 2. VARIABLE SECTION
    // #region

    wire [63:0] cache_fifoi_rxd;
    wire [7:0] cache_fifoi_rxen;

    wire [3:0] cache_null;

    wire [3:0] cache_fd_check;
    wire [3:0] cache_fs_conf;
    wire [3:0] cache_fs_read;
    wire [4:0] cache_fd_conf;
    wire [3:0] cache_fd_conf_orig;
    wire [3:0] cache_fd_read;
    wire [3:0] cache_fd_read_orig;
    
    // #endregion

    // ## 3. LOGICAL SECTION
    // #region
    // #### 1. COMBINATIONAL LOGIC PART
    // #region
    assign cache_null[3] = (dev_kind[7:6] === 2'h0);
    assign cache_null[2] = (dev_kind[5:4] === 2'h0);
    assign cache_null[1] = (dev_kind[3:2] === 2'h0);
    assign cache_null[0] = (dev_kind[1:0] === 2'h0);
    
    assign cache_fs_conf[3] = fs_conf && (~cache_null[3]);
    assign cache_fs_conf[2] = fs_conf && (~cache_null[2]);
    assign cache_fs_conf[1] = fs_conf && (~cache_null[1]);
    assign cache_fs_conf[0] = fs_conf && (~cache_null[0]);
    assign cache_fs_read[3] = fs_read && (~cache_null[3]);
    assign cache_fs_read[2] = fs_read && (~cache_null[2]);
    assign cache_fs_read[1] = fs_read && (~cache_null[1]);
    assign cache_fs_read[0] = fs_read && (~cache_null[0]);

    assign cache_fd_conf[3] = cache_fd_conf_orig[3] || (cache_null[3]); 
    assign cache_fd_conf[2] = cache_fd_conf_orig[2] || (cache_null[2]); 
    assign cache_fd_conf[1] = cache_fd_conf_orig[1] || (cache_null[1]); 
    assign cache_fd_conf[0] = cache_fd_conf_orig[0] || (cache_null[0]); 
    assign cache_fd_read[3] = cache_fd_read_orig[3] || (cache_null[3]); 
    assign cache_fd_read[2] = cache_fd_read_orig[2] || (cache_null[2]); 
    assign cache_fd_read[1] = cache_fd_read_orig[1] || (cache_null[1]); 
    assign cache_fd_read[0] = cache_fd_read_orig[0] || (cache_null[0]); 


    assign fd_conf = (cache_fd_conf == 5'h1F);
    assign fd_read = (cache_fd_read == 4'hF);
    assign fd_check = (cache_fd_check == 4'hF);

   
    // #endregion
    // #### 2. SEQUENTIAL LOGIC PART
    // #region

    // #endregion
    // #endregion

// ## 4. IP SECTION
// #region

// #### 1. INTAN 
// #region
    intan
    intan_dut0(
        .clk(clk),
        .rst(rst),
        .err(),
        .spi_mc(spi_mc),
        .fifoi_txc(fifoi_txc),
        .fifoi_rxc(fifoi_rxc),

        .dev_kind(cache_dev_kind[7:6]),

        .fs_check(fs_check),
        .fs_conf(cache_fs_conf[3]),
        .fs_read(cache_fs_read[3]),
        .fd_check(cache_fd_check[3]),
        .fd_conf(cache_fd_conf_orig[3]),
        .fd_read(cache_fd_read_orig[3]),

        .cache_fifoi_rxen(cache_fifoi_rxen[7:6]),
        .cache_fifoi_rxd(cache_fifoi_rxd[63:48]),
        .reg00(reg00),
        .reg01(reg01),
        .reg02(reg02),
        .reg03(reg03),
        .reg04(reg04),
        .reg05(reg05),
        .reg06(reg06),
        .reg07(reg07),
        .reg08(reg08),
        .reg09(reg09),
        .reg10(reg10),
        .reg11(reg11),
        .reg12(reg12),
        .reg13(reg13),
        .regap(regap),

        .miso(cache_miso[3]),
        .cs(cache_cs[3]),
        .mosi(cache_mosi[3]),
        .sclk(cache_sclk[3])
    );

    intan
    intan_dut1(
        .clk(clk),
        .rst(rst),
        .err(),
        .spi_mc(spi_mc),
        .fifoi_txc(fifoi_txc),
        .fifoi_rxc(fifoi_rxc),

        .dev_kind(cache_dev_kind[5:4]),

        .fs_check(fs_check),
        .fs_conf(cache_fs_conf[2]),
        .fs_read(cache_fs_read[2]),
        .fd_check(cache_fd_check[2]),
        .fd_conf(cache_fd_conf_orig[2]),
        .fd_read(cache_fd_read_orig[2]),

        .cache_fifoi_rxen(cache_fifoi_rxen[5:4]),
        .cache_fifoi_rxd(cache_fifoi_rxd[47:32]),
        .reg00(reg00),
        .reg01(reg01),
        .reg02(reg02),
        .reg03(reg03),
        .reg04(reg04),
        .reg05(reg05),
        .reg06(reg06),
        .reg07(reg07),
        .reg08(reg08),
        .reg09(reg09),
        .reg10(reg10),
        .reg11(reg11),
        .reg12(reg12),
        .reg13(reg13),
        .regap(regap),

        .miso(cache_miso[2]),
        .cs(cache_cs[2]),
        .mosi(cache_mosi[2]),
        .sclk(cache_sclk[2])
    );

    intan
    intan_dut2(
        .clk(clk),
        .rst(rst),
        .err(),
        .spi_mc(spi_mc),
        .fifoi_txc(fifoi_txc),
        .fifoi_rxc(fifoi_rxc),

        .dev_kind(cache_dev_kind[3:2]),

        .fs_check(fs_check),
        .fs_conf(cache_fs_conf[1]),
        .fs_read(cache_fs_read[1]),
        .fd_check(cache_fd_check[1]),
        .fd_conf(cache_fd_conf_orig[1]),
        .fd_read(cache_fd_read_orig[1]),

        .cache_fifoi_rxen(cache_fifoi_rxen[3:2]),
        .cache_fifoi_rxd(cache_fifoi_rxd[31:16]),
        .reg00(reg00),
        .reg01(reg01),
        .reg02(reg02),
        .reg03(reg03),
        .reg04(reg04),
        .reg05(reg05),
        .reg06(reg06),
        .reg07(reg07),
        .reg08(reg08),
        .reg09(reg09),
        .reg10(reg10),
        .reg11(reg11),
        .reg12(reg12),
        .reg13(reg13),
        .regap(regap),

        .miso(cache_miso[1]),
        .cs(cache_cs[1]),
        .mosi(cache_mosi[1]),
        .sclk(cache_sclk[1])
    );

    intan
    intan_dut3(
        .clk(clk),
        .rst(rst),
        .err(),
        .spi_mc(spi_mc),
        .fifoi_txc(fifoi_txc),
        .fifoi_rxc(fifoi_rxc),

        .dev_kind(cache_dev_kind[1:0]),

        .fs_check(fs_check),
        .fs_conf(cache_fs_conf[0]),
        .fs_read(cache_fs_read[0]),
        .fd_check(cache_fd_check[0]),
        .fd_conf(cache_fd_conf_orig[0]),
        .fd_read(cache_fd_read_orig[0]),

        .cache_fifoi_rxen(cache_fifoi_rxen[1:0]),
        .cache_fifoi_rxd(cache_fifoi_rxd[15:0]),
        .reg00(reg00),
        .reg01(reg01),
        .reg02(reg02),
        .reg03(reg03),
        .reg04(reg04),
        .reg05(reg05),
        .reg06(reg06),
        .reg07(reg07),
        .reg08(reg08),
        .reg09(reg09),
        .reg10(reg10),
        .reg11(reg11),
        .reg12(reg12),
        .reg13(reg13),
        .regap(regap),

        .miso(cache_miso[0]),
        .cs(cache_cs[0]),
        .mosi(cache_mosi[0]),
        .sclk(cache_sclk[0])
    );

// #### 2. FIFO2ADC
// #region

    fifo2adc 
    fifo2adc_dut(
        .clk(fifoi_rxc),
        .rst(rst),
        .err(),

        .fs_conf(fs_conf),
        .fd_conf(cache_fd_conf[4]),
        .fs_fifo(fs_fifo),
        .fd_fifo(fd_fifo),
        .fifod_txen(fifod_txen),
        .cache_fifoi_rxen(cache_fifoi_rxen),
        .cache_dev_kind(cache_dev_kind),
        .cache_dev_info(cache_dev_info),
        .dev_smpr(dev_smpr),
        .cache_fifoi_rxd(cache_fifoi_rxd),
        .fifod_txd(fifod_txd),
        .data_len(data_len)
    );
// endregion

// endregion

endmodule