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
// intan.v:
// 本文件完成芯片与INTAN芯片的连接过程

// ## 1. 具体功能
// * 1. 检测是否芯片连接正常
// * 2. 通过给定的寄存器数值，在flag_start_cf为高电平后对INTAN寄存器进行写入操作
// * 3. 在flag_start_rd为高电平后，读入各通道ADC的数据
// * 4. 在rd_en为高电平后，按通道顺序依次读取数据并输出至data

// ## 2. 时钟说明
// * 1. clk 是系统逻辑主时钟；
// * 2. spi_mc 是为spi通讯提供的母时钟；
// * 3. clk_fifo_tx 是为FIFO的写入通讯时钟
// * 4. clk_fifo_rx 是为FIFO的读写通讯时钟

// ## 3. 控制策略
// #### 1. 主系统控制策略
// * STATE -> IDLE_WAIT -> IDLE_SKIP -> NEXT_STATE;                 // 正常周期
// * STATE -> CHECK_WAIT -> CHECK_SKIP -> NEXT_STATE;               // 正常判断周期
// * STATE -> KIND_WAIT -> KIND_WORK -> KIND_SKIP -> NEXT_STATE;    // 判断芯片类型周期
// * STATE -> WRITE_WAIT -> WRITE_WORK -> WRITE_SKIP -> NEXT_STATE; // 读入ADS数据周期
// #### 2. SPI通讯
// * SPI通讯策略即使用spi.v文件
// #### 3. FIFO通讯
// * FIFO通讯分为两个部分
// ###### 1. WR_FIFO
// * FIFO写入数据: intan2fifo.v
// * FIFO读取数据: fifo2adc.v
//////////////////////////////////////////////////////////////////////////////////
// #endregion 
// 这里确定一下具体的数据顺序：
// 1. cache_fifoi_rxd[15:8] 发送的是从0-31通道的数据
// 2. cache_fifoi_rxd[7:0] 发送的是从32-63通道的数据
module intan (
    // #### 1. CRE SECTION
    input clk,
    input rst,
    output err,

    input spi_mc,
    input fifoi_txc,
    input fifoi_rxc, 

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
    output [15:0] cache_fifoi_rxd,

    // ###### 3. INTAN REGISTER CACHE PART
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

    // #### 3. SPI COMMUNICATION SECTION
    input miso,
    output cs,
    output mosi,
    output sclk
);
localparam ANS_REG40 = 8'h49;
localparam ANS_REG41 = 8'h4E;
localparam ANS_REG42 = 8'h54;
localparam ANS_REG43 = 8'h41;
localparam ANS_REG44 = 8'h4E;

localparam CMD_CONCERT0 = 16'h0000;
localparam CMD_CONCERTN = 16'h3F00;
localparam CMD_CALIBRATE = 16'h5500;
localparam CMD_CKEAR = 16'h6A00;
localparam CMD_WRITE = 2'b10;
localparam CMD_READ = 2'b11;

localparam RET_WRITE = 8'hFF;
localparam RET_READ = 8'h00;

localparam REG00 = 6'h00, REG01 = 6'h01, REG02 = 6'h02, REG03 = 6'h03;
localparam REG04 = 6'h04, REG05 = 6'h05, REG06 = 6'h06, REG07 = 6'h07;
localparam REG08 = 6'h08, REG09 = 6'h09, REG10 = 6'h0A, REG11 = 6'h0B;
localparam REG12 = 6'h0C, REG13 = 6'h0D, REG14 = 6'h0E, REG15 = 6'h0F;
localparam REG16 = 6'h10, REG17 = 6'h11, REG18 = 6'h12, REG19 = 6'h13;
localparam REG20 = 6'h14, REG21 = 6'h15, REG40 = 6'h28, REG41 = 6'h29;
localparam REG42 = 6'h2A, REG43 = 6'h2B, REG44 = 6'h2C, REG59 = 6'h3B;
localparam REG60 = 6'h3C, REG61 = 6'h3D, REG62 = 6'h3E, REG63 = 6'h3F;

// STATE //

// STATE_INTAN
localparam MAIN_IDLE = 8'h00, MAIN_DEAD = 8'h01, DYG_CHECK = 8'h02, DYG_CONF = 8'h03;
localparam IDLE_WAIT = 8'h06, CHECK_WAIT = 8'h07, KIND_WAIT = 8'h08, WRITE_WAIT = 8'h09;
localparam KIND_WORK = 8'h0A, WRITE_WORK = 8'h0B;
localparam IDLE_SKIP = 8'h0C, CHECK_SKIP = 8'h0D, KIND_SKIP = 8'h0E, WRITE_SKIP = 8'h0F;

localparam IDLE_CHECK = 8'h20;
localparam CHECK_CREG40 = 8'h21, CHECK_CREG41 = 8'h22, CHECK_CREG42 = 8'h23;
localparam CHECK_CREG43 = 8'h24, CHECK_CREG44 = 8'h25, CHECK_CHIPID = 8'h26;
localparam CHECK_NUMAMP = 8'h27, RDREG_CHIPID = 8'h28, RDREG_NUMAMP = 8'h29;
localparam CHECK_DRDREG = 8'h2A, CHECK_DOWAIT = 8'h2B, CHECK_DCHECK = 8'h2C;
localparam CHECK_LAST = 8'h2D, CHECK_DONE = 8'h2E;

localparam IDLE_CONF = 8'h30;
localparam CONFIG_REG00 = 8'h31, CONFIG_REG01 = 8'h83, CONFIG_REG02 = 8'h33;
localparam CONFIG_REG03 = 8'h34, CONFIG_REG04 = 8'h35, CONFIG_REG05 = 8'h36;
localparam CONFIG_REG06 = 8'h37, CONFIG_REG07 = 8'h38, CONFIG_REG08 = 8'h39;
localparam CONFIG_REG09 = 8'h3A, CONFIG_REG10 = 8'h3B, CONFIG_REG11 = 8'h3C;
localparam CONFIG_REG12 = 8'h3D, CONFIG_REG13 = 8'h3E, CONFIG_REG14 = 8'h3F;
localparam CONFIG_REG15 = 8'h40, CONFIG_REG16 = 8'h41, CONFIG_REG17 = 8'h42;
localparam CONFIG_REG18 = 8'h43, CONFIG_REG19 = 8'h44, CONFIG_REG20 = 8'h45;
localparam CONFIG_REG21 = 8'h46, CONFIG_CHECK0 = 8'h47, CONFIG_CHECK1 = 8'h48;
localparam CONFIG_CALIBRATE = 8'h49, CONFIG_DUMMY0 = 8'h4A, CONFIG_DUMMY1 = 8'h4B;
localparam CONFIG_DUMMY2 = 8'h4C, CONFIG_DUMMY3 = 8'h4D, CONFIG_DUMMY4 = 8'h4E;
localparam CONFIG_DUMMY5 = 8'h4F, CONFIG_DUMMY6 = 8'h50, CONFIG_DUMMY7 = 8'h51;
localparam CONFIG_DUMMY8 = 8'h52;
localparam CONFIG_FREAD = 8'h53, CONFIG_FWAIT = 8'h54, CONFIG_FCHECK = 8'h55;
localparam CONFIG_DWRREG = 8'h56, CONFIG_DOWAIT = 8'h57, CONFIG_DCHECK = 8'h58;
localparam CONFIG_DONE = 8'h59;

localparam IDLE_CONV = 8'h60;
localparam CONV_CH00 = 8'h61, CONV_CH01 = 8'h62, CONV_CH02 = 8'h63;
localparam CONV_CH03 = 8'h64, CONV_CH04 = 8'h65, CONV_CH05 = 8'h66;
localparam CONV_CH06 = 8'h67, CONV_CH07 = 8'h68, CONV_CH08 = 8'h69;
localparam CONV_CH09 = 8'h6A, CONV_CH10 = 8'h6B, CONV_CH11 = 8'h6C;
localparam CONV_CH12 = 8'h6D, CONV_CH13 = 8'h6E, CONV_CH14 = 8'h6F;
localparam CONV_CH15 = 8'h70, CONV_CH16 = 8'h71, CONV_CH17 = 8'h72;
localparam CONV_CH18 = 8'h73, CONV_CH19 = 8'h74, CONV_CH20 = 8'h75;
localparam CONV_CH21 = 8'h76, CONV_CH22 = 8'h77, CONV_CH23 = 8'h78;
localparam CONV_CH24 = 8'h79, CONV_CH25 = 8'h7A, CONV_CH26 = 8'h7B;
localparam CONV_CH27 = 8'h7C, CONV_CH28 = 8'h7D, CONV_CH29 = 8'h7E;
localparam CONV_CH30 = 8'h7F, CONV_CH31 = 8'h80;
localparam CONV_CHECK0 = 8'h81, CONV_CHECK1 = 8'h82, CONV_DONE = 8'h83;

// STATE_FIFO
localparam FIFO_IDLE = 3'h0, FIFO_PREP = 3'h1;
localparam FIFO_DATA0 = 3'h2, FIFO_DATA1 = 3'h3, FIFO_LAST = 3'h4;

// CHECK
reg [1:0] dev_kind0, dev_kind1; // dev_kind0通过芯片型号判断；dev_kind1通过芯片通道数判断

// CONTROL
reg [7:0] state;
reg [7:0] next_state;
reg [7:0] back_state;

// SPI CONTROL
reg [15:0] data_check;

// SPI SIGNAL
reg fs_prd;
wire fd_spi;
wire fd_prd;

// SPI DATA
reg [15:0] chip_txd;
wire [15:0] chip_rxd0;
wire [15:0] chip_rxd1;
wire [15:0] fifoi_txd;

// FIFO CONTROL
reg fifoi_txen;
reg fs_fifo;
wire fd_fifo;
// FIFO DATA
reg [7:0] fifo_data0, fifo_data1;
// ERROR
reg reg_error_check;

assign fd_read = (state == CONV_DONE);
assign fd_check = (state == CHECK_DONE || (state == DYG_CHECK));
assign fd_conf = (state == CONFIG_DONE || (state == DYG_CONF));

always @(posedge clk or posedge rst) begin // state
    if(rst) begin
        state <= MAIN_IDLE;
    end
    else begin
        case(state)
            // MAIN
            // #region
            MAIN_IDLE: begin
                if (fs_check) begin
                    state <= IDLE_CHECK;
                end
                else if(fs_conf) begin
                    state <= IDLE_CONF;
                end
                else if(fs_read) begin
                    state <= IDLE_CONV;
                end 
                else begin
                    state <= MAIN_IDLE;
                end
            end
            DYG_CHECK: begin
                dev_kind <= 2'h0;
                if(fs_check == 1'b0) begin
                    state <= MAIN_DEAD;
                end
            end
            DYG_CONF: begin
                if(fs_conf == 1'b0) begin
                    state <= MAIN_DEAD;
                end
            end
            MAIN_DEAD: begin
                dev_kind <= 2'h0;
                state <= MAIN_DEAD;
            end

            // STATE PROCEDURE
            // #region
            IDLE_WAIT: begin
                if(fd_spi) begin
                    state <= IDLE_SKIP;
                    fs_prd <= 1'b0;
                end
                else begin
                    fs_prd <= 1'b1;
                    state <= IDLE_WAIT;
                end
            end
            CHECK_WAIT: begin
                if(fd_spi) begin
                    state <= CHECK_SKIP;
                    fs_prd <= 1'b0;
                end
                else begin
                    fs_prd <= 1'b1;
                    state <= CHECK_WAIT;
                end
            end
            KIND_WAIT: begin
                if(fd_spi) begin
                    state <= KIND_WORK;
                    fs_prd <= 1'b0;
                end
                else begin
                    fs_prd <= 1'b1;
                    state <= KIND_WAIT;
                end
            end
            WRITE_WAIT: begin
                if(fd_spi) begin
                    state <= WRITE_WORK;
                    fs_fifo <= 1'b1;
                    fs_prd <= 1'b0;
                end
                else begin
                    fs_prd <= 1'b1;
                    state <= WRITE_WAIT;
                end
            end
            IDLE_SKIP: begin
                if(fd_prd) begin
                    state <= next_state;
                end
                else begin
                    state <= IDLE_SKIP;
                end
            end
            CHECK_SKIP: begin
                if(fd_prd && chip_rxd0 == data_check) begin
                    state <= next_state;
                end
                else if(fd_prd && chip_rxd0 != data_check) begin
                    state <= back_state;
                end
                else begin
                    state <= CHECK_SKIP;
                end
            end
            KIND_WORK: begin
                if(fd_prd) begin
                    state <= KIND_SKIP;
                end
                else begin
                    state <= KIND_WORK;
                end
            end
            KIND_SKIP: begin
                case(chip_rxd0[7:0]) 
                    8'h01: begin // CHIP_ID = 1 为 RHD2132;
                        dev_kind0 <= 2'b10;
                        state <= next_state;
                    end
                    8'h02: begin // CHIP_ID = 2 为 RHD2116;
                        dev_kind0 <= 2'b01;
                        state <= next_state;
                    end
                    8'h04: begin // CHIP_ID = 4 为 RHD2164;
                        dev_kind0 <= 2'b11;
                        state <= next_state;
                    end
                    8'h10: begin // NUM_AMP = 16 为 RHD2116;
                        dev_kind1 <= 2'b01;
                        state <= next_state;
                    end
                    8'h20: begin // NUM_AMP = 32 为 RHD2132;
                        dev_kind1 <= 2'b10;
                        state <= next_state;
                    end
                    8'h40: begin // NUM_AMP = 64 为 RHD2164;
                        dev_kind1 <= 2'b11;
                        state <= next_state;
                    end
                    default: begin
                        state <= back_state;
                    end
                endcase
            end
            WRITE_WORK: begin
                if(fd_fifo) begin
                    fs_fifo <= 1'b0;
                    state <= WRITE_SKIP;
                end
                else begin
                    state <= WRITE_WORK;
                end
            end
            WRITE_SKIP: begin
                if(fd_prd) begin
                    state <= next_state;
                end
                else begin
                    state <= WRITE_SKIP;
                end
            end
            // endregion
            
            // STATE PRECHECK
            // #region
            IDLE_CHECK: begin
                state <= CHECK_CREG40;
            end
            CHECK_CREG40: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CHECK_CREG41;
                state <= IDLE_WAIT;
            end
            CHECK_CREG41: begin
                chip_txd <= {CMD_READ, REG41, RET_READ};
                next_state <= CHECK_CREG42;
                state <= IDLE_WAIT;
            end
            CHECK_CREG42: begin
                chip_txd <= {CMD_READ, REG42, RET_READ};
                next_state <= CHECK_CREG43;
                back_state <= CHECK_DRDREG;
                data_check <= {RET_READ, ANS_REG40};
                state <= CHECK_WAIT;
            end
            CHECK_CREG43: begin
                chip_txd <= {CMD_READ, REG43, RET_READ};
                next_state <= CHECK_CREG44;
                back_state <= CHECK_DRDREG;
                data_check <= {RET_READ, ANS_REG41};
                state <= CHECK_WAIT;
            end
            CHECK_CREG44: begin
                chip_txd <= {CMD_READ, REG44, RET_READ};
                next_state <= CHECK_CHIPID;
                back_state <= CHECK_DRDREG;
                data_check <= {RET_READ, ANS_REG42};
                state <= CHECK_WAIT;
            end 
            CHECK_CHIPID: begin
                chip_txd <= {CMD_READ, REG62, RET_READ};
                next_state <= CHECK_NUMAMP;
                back_state <= CHECK_DRDREG;
                data_check <= {RET_READ, ANS_REG43};
                state <= CHECK_WAIT;
            end
            CHECK_NUMAMP: begin
                chip_txd <= {CMD_READ, REG63, RET_READ};
                next_state <= RDREG_CHIPID;
                back_state <= CHECK_DRDREG;
                data_check <= {RET_READ, ANS_REG44};
                state <= CHECK_WAIT;
            end
            RDREG_CHIPID: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= RDREG_NUMAMP;
                back_state <= CHECK_DRDREG;
                state <= KIND_WAIT;
            end
            RDREG_NUMAMP: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CHECK_LAST;
                back_state <= CHECK_DRDREG;
                state <= KIND_WAIT;
            end
            CHECK_LAST: begin
                if(dev_kind0 == dev_kind1) begin
                    dev_kind <= dev_kind0;
                    state <= CHECK_DONE;
                end
                else state <= DYG_CHECK;
            end
            CHECK_DONE: begin
                if(fs_check == 1'b0) begin
                    state <= MAIN_IDLE;
                end
                else begin
                    state <= CHECK_LAST;
                end
            end
            // endregion

            // STATE OPTION
            // #region
            IDLE_CONF: begin
                state <= CONFIG_REG00;
            end
            CONFIG_REG00: begin
                chip_txd <= {CMD_WRITE, REG00, reg00};
                next_state <= WRITE_REG01;
                state <= IDLE_WAIT;
            end
            CONFIG_REG01: begin
                chip_txd <= {CMD_WRITE, REG01, reg01};
                next_state <= WRITE_REG02;
                state <= IDLE_WAIT;
            end
            CONFIG_REG02: begin
                chip_txd <= {CMD_WRITE, REG02, reg02};
                next_state <= WRITE_REG03;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg00};
                state <= CHECK_WAIT;
            end
            CONFIG_REG03: begin
                chip_txd <= {CMD_WRITE, REG03, reg03};
                next_state <= WRITE_REG04;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg01};
                state <= CHECK_WAIT;
            end
            CONFIG_REG04: begin
                chip_txd <= {CMD_WRITE, REG04, reg04};
                next_state <= WRITE_REG05;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg02};
                state <= CHECK_WAIT;
            end
            CONFIG_REG05: begin
                chip_txd <= {CMD_WRITE, REG05, reg05};
                next_state <= WRITE_REG06;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg03};
                state <= CHECK_WAIT;
            end
            CONFIG_REG06: begin
                chip_txd <= {CMD_WRITE, REG06, reg06};
                next_state <= WRITE_REG07;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg04};
                state <= CHECK_WAIT;
            end
            CONFIG_REG07: begin
                chip_txd <= {CMD_WRITE, REG07, reg07};
                next_state <= WRITE_REG08;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg05};
                state <= CHECK_WAIT;
            end
            CONFIG_REG08: begin
                chip_txd <= {CMD_WRITE, REG08, reg08};
                next_state <= WRITE_REG09;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg06};
                state <= CHECK_WAIT;
            end
            CONFIG_REG09: begin
                chip_txd <= {CMD_WRITE, REG09, reg09};
                next_state <= WRITE_REG10;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg07};
                state <= CHECK_WAIT;
            end
            CONFIG_REG10: begin
                chip_txd <= {CMD_WRITE, REG10, reg10};
                next_state <= WRITE_REG11;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg08};
                state <= CHECK_WAIT;
            end
            CONFIG_REG11: begin
                chip_txd <= {CMD_WRITE, REG11, reg11};
                next_state <= WRITE_REG12;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg09};
                state <= CHECK_WAIT;
            end
            CONFIG_REG12: begin
                chip_txd <= {CMD_WRITE, REG12, reg12};
                next_state <= WRITE_REG13;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg10};
                state <= CHECK_WAIT;
            end
            CONFIG_REG13: begin
                chip_txd <= {CMD_WRITE, REG13, reg13};
                next_state <= WRITE_REG14;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg11};
                state <= CHECK_WAIT;
            end
            CONFIG_REG14: begin
                chip_txd <= {CMD_WRITE, REG14, regap};
                next_state <= WRITE_REG15;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg12};
                state <= CHECK_WAIT;
            end
            CONFIG_REG15: begin
                chip_txd <= {CMD_WRITE, REG15, regap};
                case(dev_kind) 
                    2'b01: next_state <= CONFIG_CHECK0;
                    2'b10: next_state <= CONFIG_REG16;
                    2'b11: next_state <= CONFIG_REG16;
                    default: next_state <= DYG_CONF;
                endcase
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, reg13};
                state <= CHECK_WAIT;
            end
            CONFIG_REG16: begin
                chip_txd <= {CMD_WRITE, REG16, regap};
                next_state <= WRITE_REG17;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, regap};
                state <= CHECK_WAIT;
            end
            CONFIG_REG17: begin
                chip_txd <= {CMD_WRITE, REG17, regap};
                case(dev_kind) 
                    2'b10: next_state <= CONFIG_CHECK0;
                    2'b11: next_state <= CONFIG_REG18;
                    default: next_state <= DYG_CONF;
                endcase
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, regap};
                state <= CHECK_WAIT;
            end
            CONFIG_REG18: begin
                chip_txd <= {CMD_WRITE, REG18, regap};
                next_state <= WRITE_REG19;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, regap};
                state <= CHECK_WAIT;
            end
            CONFIG_REG19: begin
                chip_txd <= {CMD_WRITE, REG19, regap};
                next_state <= WRITE_REG20;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, regap};
                state <= CHECK_WAIT;
            end
            CONFIG_REG20: begin
                chip_txd <= {CMD_WRITE, REG20, regap};
                next_state <= WRITE_REG21;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, regap};
                state <= CHECK_WAIT;
            end
            CONFIG_REG21: begin
                chip_txd <= {CMD_WRITE, REG21, regap};
                next_state <= WRITE_REG03;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, regap};
                state <= CHECK_WAIT;
            end
            CONFIG_CHECK0: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= WRITE_CHECK0;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, regap};
                state <= CHECK_WAIT;
            end
            CONFIG_CHECK1: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= WRITE_CALIBRATE;
                back_state <= COFNIG_DWRREG;
                data_check <= {RET_WRITE, regap};
                state <= CHECK_WAIT;
            end
            CONFIG_CALIBRATE: begin
                chip_txd <= CMD_CALIBRATE;
                next_state <= CONFIG_DUMMY0;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY0: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DUMMY1;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY1: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DUMMY2;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY2: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DUMMY3;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY3: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DUMMY4;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY4: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DUMMY5;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY5: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DUMMY6;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY6: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DUMMY7;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY7: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DUMMY8;
                state <= IDLE_WAIT;
            end
            CONFIG_DUMMY8: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_FREAD;
                state <= IDLE_WAIT;
            end
            CONFIG_FREAD: begin
                chip_txd <= {CMD_READ, REG41, RET_READ};
                next_state <= CONFIG_FWAIT;
                state <= IDLE_WAIT;
            end
            CONFIG_FWAIT: begin
                chip_txd <= {CMD_READ, REG42, RET_READ};
                next_state <= CONFIG_FCHECK;
                state <= IDLE_WAIT;
            end
            CONFIG_FCHECK: begin
                chip_txd <= {CMD_READ, REG43, RET_READ};
                next_state <= CONFIG_DONE;
                back_state <= CONFIG_FREAD;
                data_check <= {RET_READ, ANS_REG41};
                state <= CHECK_WAIT;;
            end
            CONFIG_DWRREG: begin
                chip_txd <= {CMD_WRITE, REG00, reg00};
                next_state <= CONFIG_DOWAIT;
                state <= IDLE_WAIT;
            end
            CONFIG_DOWAIT: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONFIG_DCHECK;
                state <= IDLE_WAIT;
            end
            CONFIG_DCHECK: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= IDLE_CONFIG;
                back_state <= DYG_CONF;
                data_check <= {RET_WRITE, reg00};
                state <= CHECK_WAIT;
            end
            CONFIG_DONE: begin
                if(fd_conf) begin
                    state <= MAIN_IDLE;
                end
                else begin
                    state <= CONFIG_DONE;
                end
            end
            // endregion

            // STATE READ
            // #region
            IDLE_CONV: begin
                state <= CONV_CH00;
            end
            CONV_CH00: begin
                chip_txd <= CMD_CONCERT0;
                next_state <= CONV_CH01;
                state <= IDLE_WAIT;
            end
            CONV_CH01: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH02;
                state <= IDLE_WAIT;
            end
            CONV_CH02: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH03;
                state <= WRITE_WAIT;
            end
            CONV_CH03: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH04;
                state <= WRITE_WAIT;
            end
            CONV_CH04: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH05;
                state <= WRITE_WAIT;
            end 
            CONV_CH05: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH06;
                state <= WRITE_WAIT;
            end
            CONV_CH06: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH07;
                state <= WRITE_WAIT;
            end
            CONV_CH07: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH08;
                state <= WRITE_WAIT;
            end
            CONV_CH08: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH09;
                state <= WRITE_WAIT;
            end
            CONV_CH09: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH10;
                state <= WRITE_WAIT;
            end
            CONV_CH10: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH11;
                state <= WRITE_WAIT;
            end
            CONV_CH11: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH12;
                state <= WRITE_WAIT;
            end
            CONV_CH12: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH13;
                state <= WRITE_WAIT;
            end
            CONV_CH13: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH14;
                state <= WRITE_WAIT;
            end
            CONV_CH14: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH15;
                state <= WRITE_WAIT;
            end
            CONV_CH15: begin
                chip_txd <= CMD_CONCERTN;
                state <= WRITE_WAIT;
                if(dev_kind[1] == 1'b0) begin
                    next_state <= CONV_CHECK0;
                end
                else begin
                    next_state <= CONV_CH16;
                end
            end
            CONV_CH16: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH17;
                state <= WRITE_WAIT;
            end
            CONV_CH17: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH18;
                state <= WRITE_WAIT;
            end
            CONV_CH18: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH19;
                state <= WRITE_WAIT;
            end
            CONV_CH19: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH20;
                state <= WRITE_WAIT;
            end
            CONV_CH20: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH21;
                state <= WRITE_WAIT;
            end
            CONV_CH21: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH22;
                state <= WRITE_WAIT;
            end
            CONV_CH22: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH23;
                state <= WRITE_WAIT;
            end
            CONV_CH23: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH24;
                state <= WRITE_WAIT;
            end
            CONV_CH24: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH25;
                state <= WRITE_WAIT;
            end
            CONV_CH25: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH26;
                state <= WRITE_WAIT;
            end
            CONV_CH26: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH27;
                state <= WRITE_WAIT;
            end
            CONV_CH27: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH28;
                state <= WRITE_WAIT;
            end
            CONV_CH28: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH29;
                state <= WRITE_WAIT;
            end
            CONV_CH29: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH30;
                state <= WRITE_WAIT;
            end
            CONV_CH30: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CH31;
                state <= WRITE_WAIT;
            end
            CONV_CH31: begin
                chip_txd <= CMD_CONCERTN;
                next_state <= CONV_CHECK0;
                state <= WRITE_WAIT;
            end
            CONV_CHECK0: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONV_CHECK1;
                state <= WRITE_WAIT;
            end
            CONV_CHECK1: begin
                chip_txd <= {CMD_READ, REG40, RET_READ};
                next_state <= CONV_DONE;
                state <= WRITE_WAIT;
            end
            CONV_DONE: begin
                if(fs_read == 1'b0) begin
                    state <= MAIN_IDLE;
                end
                else begin
                    state <= CONV_DONE;
                end
            end
            // endregion
        endcase
    end
end

    spi2fifoi
    spi2fifoi_dut(
        .clk(fifoi_txc),
        .rst(rst),
        .err(),

        .fs(fs_fifo),
        .fd(fd_fifo),

        .chip_rxd0(chip_rxd0),
        .chip_rxd1(chip_rxd1),
        .fifoi_txen(fifoi_txen),
        .fifoi_txd(fifoi_txd)
    );


    spi
    spi_dut(
        .clk(spi_mc),
        .rst(rst),
        .err(),

        .fs(fs_prd),
        .fd_spi(fd_spi),
        .fd_prd(fd_prd),

        .miso(miso),
        .cs(cs),
        .mosi(mosi),
        .sclk(sclk),

        .chip_txd(chip_txd),
        .chip_rxd0(chip_rxd0),
        .chip_rxd1(chip_rxd1)
    );

    fifoi
    fifoi_dut0(
        .rst(rst),
        .wr_clk(fifoi_txc),
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