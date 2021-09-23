// #1 0. DOCUMENT SECTION
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
// spi.v:
// 该文件完成与INTAN芯片的SPI的一次通讯
// 由于INTAN64与另外两款的区别仅在于在SCLK的下降沿也读取一位数据，故这里把下降沿读取数据也写入
// 其中，上升沿记录的数据为chip_rxd0, 下降沿记录的数据为chip_rxd1
// 如果是INTAN16或INTAN32，则仅仅需要读取chip_rxd0即可；
// 如果是INTAN64，则需要读取chip_rxd0和chip_rxd1

// #1 1. 时钟说明
// * 该文件运行一次为80个clk周期
// * sclk周期为4个clk周期

// #1 2. 控制策略
// * 该文件需使用fs开始运行，至fd_spi升为高电平，
// * 完成读取chip_rxd0, chip_rxd1数据至芯片中;
// * 完成写入chip_txd数据至INTAN芯片中；
// * 至fd_prd升为高电平，则完成此次读取循环。才可以重新监听fs，重新开始新的读写
// 
// [] 本文件时序参考自
// [] 1. Intan_RHD2000_series_datasheet P.15 Timing Diagram
// [] 2. Intan_RHD2164_datasheet P.11 DDR Timing Diagram
//////////////////////////////////////////////////////////////////////////////////
// #endregion 

// 这里确定一下具体的数据顺序：
// chip_rxd0 发送的是从0-31通道数据
// chip_rxd1 发送的是从32-63通道数据

module spi (
    // #2 1. CRE SECTION
    input clk,
    input rst,
    output err,

    // #2 2. CONTROL SECTION
    input fs,
    output reg fd_spi, 
    output reg fd_prd, 

    // #2 3. SPI COMMUNICATION SECTION
    input miso,
    output reg cs,
    output reg mosi,
    output reg sclk,

    // #2 4. DATA SECTION
    input [15:0] chip_txd,
    output reg [15:0] chip_rxd0,
    output reg [15:0] chip_rxd1
);

    // #1 1. VARIABLE SECTION
    // #region
    reg[6:0] state; // 主状态机
    // #endregion

    // #1 2. LOGICAL SECTION
    // #region 
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            cs <= 1'b1;
            mosi <= 1'b0;
            sclk <= 1'b0;
            state <= 7'h7F;
            fd_spi <= 1'b0;
            fd_prd <= 1'b0;
            chip_rxd0 <= 16'h0;
            chip_rxd1 <= 16'h0;
        end
        else begin
            case(state)
                7'h7F: begin
                    cs <= 1'b1;
                    mosi <= 1'b0;
                    sclk <= 1'b0;
                    fd_spi <= 1'b0;
                    if(fs) begin
                        fd_prd <= 1'b0;
                        state <= 7'h00;
                    end
                    else begin
                        fd_prd <= fd_prd;
                    end
                end
                7'h00: begin
                    cs <= 1'b0;
                    state <= 7'h01;
                end
                7'h01: begin
                    mosi <= chip_txd[15];
                    state <= 7'h02;
                end
                7'h02: begin
                    sclk <= 1'b1;
                    state <= 7'h03;
                end
                7'h03: begin
                    state <= 7'h04;
                end
                7'h04: begin
                    sclk <= 1'b0;
                    chip_rxd0[15] <= miso;
                    state <= 7'h05;
                end
                7'h05: begin
                    mosi <= chip_txd[14];
                    state <= 7'h06;
                end
                7'h06: begin
                    sclk <= 1'b1;
                    chip_rxd1[15] <= miso;
                    state <= 7'h07;
                end
                7'h07: begin
                    state <= 7'h08;
                end
                7'h08: begin
                    sclk <= 1'b0;
                    chip_rxd0[14] <= miso;
                    state <= 7'h09;
                end
                7'h09: begin
                    mosi <= chip_txd[13];
                    state <= 7'h0A;
                end
                7'h0A: begin
                    sclk <= 1'b1;
                    chip_rxd1[14] <= miso;
                    state <= 7'h0B;
                end
                7'h0B: begin
                    state <= 7'h0C;
                end
                7'h0C: begin
                    sclk <= 1'b0;
                    chip_rxd0[13] <= miso;
                    state <= 7'h0D;
                end
                7'h0D: begin
                    mosi <= chip_txd[12];
                    state <= 7'h0E;
                end
                7'h0E: begin
                    sclk <= 1'b1;
                    chip_rxd1[13] <= miso;
                    state <= 7'h0F;
                end
                7'h0F: begin
                    state <= 7'h10;
                end
                7'h10: begin
                    sclk <= 1'b0;
                    chip_rxd0[12] <= miso;
                    state <= 7'h11;
                end
                7'h11: begin
                    mosi <= chip_txd[11];
                    state <= 7'h12;
                end
                7'h12: begin
                    sclk <= 1'b1;
                    chip_rxd1[12] <= miso;
                    state <= 7'h13;
                end
                7'h13: begin
                    state <= 7'h14;
                end
                7'h14: begin
                    sclk <= 1'b0;
                    chip_rxd0[11] <= miso;
                    state <= 7'h15;
                end
                7'h15: begin
                    mosi <= chip_txd[10];
                    state <= 7'h16;
                end
                7'h16: begin
                    sclk <= 1'b1;
                    chip_rxd1[11] <= miso;
                    state <= 7'h17;
                end
                7'h17: begin
                    state <= 7'h18;
                end
                7'h18: begin
                    sclk <= 1'b0;
                    chip_rxd0[10] <= miso;
                    state <= 7'h19;
                end
                7'h19: begin
                    mosi <= chip_txd[9];
                    state <= 7'h1A;
                end
                7'h1A: begin
                    sclk <= 1'b1;
                    chip_rxd1[10] <= miso;
                    state <= 7'h1B;
                end
                7'h1B: begin
                    state <= 7'h1C;
                end
                7'h1C: begin
                    sclk <= 1'b0;
                    chip_rxd0[9] <= miso;
                    state <= 7'h1D;
                end
                7'h1D: begin
                    mosi <= chip_txd[8];
                    state <= 7'h1E;
                end
                7'h1E: begin
                    sclk <= 1'b1;
                    chip_rxd1[9] <= miso;
                    state <= 7'h1F;
                end
                7'h1F: begin
                    state <= 7'h20;
                end
                7'h20: begin
                    sclk <= 1'b0;
                    chip_rxd0[8] <= miso;
                    state <= 7'h21;
                end
                7'h21: begin
                    mosi <= chip_txd[7];
                    state <= 7'h22;
                end
                7'h22: begin
                    sclk <= 1'b1;
                    chip_rxd1[8] <= miso;
                    state <= 7'h23;
                end
                7'h23: begin
                    state <= 7'h24;
                end
                7'h24: begin
                    sclk <= 1'b0;
                    chip_rxd0[7] <= miso;
                    state <= 7'h25;
                end
                7'h25: begin
                    mosi <= chip_txd[6];
                    state <= 7'h26;
                end
                7'h26: begin
                    sclk <= 1'b1;
                    chip_rxd1[7] <= miso;
                    state <= 7'h27;
                end
                7'h27: begin
                    state <= 7'h28;
                end
                7'h28: begin
                    sclk <= 1'b0;
                    chip_rxd0[6] <= miso;
                    state <= 7'h29;
                end
                7'h29: begin
                    mosi <= chip_txd[5];
                    state <= 7'h2A;
                end
                7'h2A: begin
                    sclk <= 1'b1;
                    chip_rxd1[6] <= miso;
                    state <= 7'h2B;
                end
                7'h2B: begin
                    state <= 7'h2C;
                end
                7'h2C: begin
                    sclk <= 1'b0;
                    chip_rxd0[5] <= miso;
                    state <= 7'h2D;
                end
                7'h2D: begin
                    mosi <= chip_txd[4];
                    state <= 7'h2E;
                end
                7'h2E: begin
                    sclk <= 1'b1;
                    chip_rxd1[5] <= miso;
                    state <= 7'h2F;
                end
                7'h2F: begin
                    state <= 7'h30;
                end
                7'h30: begin
                    sclk <= 1'b0;
                    chip_rxd0[4] <= miso;
                    state <= 7'h31;
                end
                7'h31: begin
                    mosi <= chip_txd[3];
                    state <= 7'h32;
                end
                7'h32: begin
                    sclk <= 1'b1;
                    chip_rxd1[4] <= miso;
                    state <= 7'h33;
                end
                7'h33: begin
                    state <= 7'h34;
                end
                7'h34: begin
                    sclk <= 1'b0;
                    chip_rxd0[3] <= miso;
                    state <= 7'h35;
                end
                7'h35: begin
                    mosi <= chip_txd[2];
                    state <= 7'h36;
                end
                7'h36: begin
                    sclk <= 1'b1;
                    chip_rxd1[3] <= miso;
                    state <= 7'h37;
                end
                7'h37: begin
                    state <= 7'h38;
                end
                7'h38: begin
                    sclk <= 1'b0;
                    chip_rxd0[2] <= miso;
                    state <= 7'h39;
                end
                7'h39: begin
                    mosi <= chip_txd[1];
                    state <= 7'h3A;
                end
                7'h3A: begin
                    sclk <= 1'b1;
                    chip_rxd1[2] <= miso;
                    state <= 7'h3B;
                end
                7'h3B: begin
                    state <= 7'h3C;
                end
                7'h3C: begin
                    sclk <= 1'b0;
                    chip_rxd0[1] <= miso;
                    state <= 7'h3D;
                end
                7'h3D: begin
                    mosi <= chip_txd[0];
                    state <= 7'h3E;
                end
                7'h3E: begin
                    sclk <= 1'b1;
                    chip_rxd1[1] <= miso;
                    state <= 7'h3F;
                end
                7'h3F: begin
                    state <= 7'h40;
                end
                7'h40: begin
                    sclk <= 1'b0;
                    chip_rxd0[0] <= miso;
                    state <= 7'h41;
                end
                7'h41: begin
                    state <= 7'h42;
                    mosi <= 1'b0;
                end
                7'h42: begin
                    sclk <= 1'b0;
                    chip_rxd1[0] <= miso;
                    state <= 7'h43;
                end
                7'h43: begin
                    cs <= 1'b1;
                    sclk <= 1'b0;
                    fd_spi <= 1'b1;
                    mosi <= 1'b0;
                    state <= 7'h44;
                end
                7'h44: state <= 7'h45;
                7'h45: state <= 7'h46;
                7'h46: state <= 7'h47;
                7'h47: state <= 7'h48;
                7'h48: state <= 7'h49;
                7'h49: state <= 7'h4A;
                7'h4A: state <= 7'h4B;
                7'h4B: state <= 7'h4C;
                7'h4C: state <= 7'h4D;
                7'h4D: state <= 7'h4E;
                7'h4E: begin
                    fd_spi <= 1'b0;
                    fd_prd <= 1'b1;
                    state <= 7'h7F;
                end
                default: state <= 7'h7F;
            endcase
        end
    end
    // #endregion

endmodule