module cs_cmd2reg( // TEST_DONE
    input [7:0] cmd_filt, // [7:4] UPPER_BW [3:0] LOWER_BW
    input [7:0] cmd_mix0, // [7:4] ADC_OPT  [3:1] DOUT  
    input [7:0] cmd_mix1, // [7:4] ID       [3:2] DIN   [1:0] 01
    input [7:0] cmd_reg4,
    input [7:0] cmd_reg5,
    input [7:0] cmd_reg6,
    input [7:0] cmd_reg7,

    output [7:0] reg00,
    output [7:0] reg01,
    output [7:0] reg02,
    output [7:0] reg03,
    output [7:0] reg04,
    output [7:0] reg05,
    output [7:0] reg06,
    output [7:0] reg07,
    output [7:0] reg08,
    output [7:0] reg09,
    output [7:0] reg10,
    output [7:0] reg11,
    output [7:0] reg12,
    output [7:0] reg13,

    output [7:0] regap, // Individual Amplifier Power
    output [3:0] devid,
    output dev_grp

);
/*
  UPPER_BW   REG8    REG9    REGA    REGB
00: 100Hz    0x26    0x1A    0x05    0x1F
01: 150Hz    0x2C    0x11    0x08    0x15
02: 200Hz    0x18    0x0D    0x07    0x10
03: 250Hz    0x2A    0x0A    0x05    0x0D
04: 300Hz    0x06    0x09    0x02    0x0B
05: 500Hz    0x1E    0x05    0x2B    0x06
06: 750Hz    0x29    0x03    0x24    0x04
07: 1.0kHz   0x2E    0x02    0x1E    0x03
08: 1.5kHz   0x01    0x02    0x17    0x02
09: 2.0kHz   0x1B    0x01    0x2C    0x01
0A: 2.5kHz   0x0D    0x01    0x19    0x01
0B: 3.0kHz   0x03    0x01    0x0D    0x01
0C: 5.0kHz   0x21    0x00    0x25    0x00
0D: 7.5kHz   0x16    0x00    0x17    0x00
0E: 10kHz    0x11    0x00    0x10    0x00
0F: 15kHz    0x0B    0x00    0x08    0x00

  LOWER_BW   REGC    REGD
00: 0.25Hz   0x38    0x36
01: 0.50Hz   0x23    0x11
02: 1.0Hz    0x2C    0x06
03: 2.0Hz    0x08    0x03
04: 2.5Hz    0x2A    0x02
05: 3.0Hz    0x14    0x02
06: 5.0Hz    0x28    0x01
07: 7.5Hz    0x12    0x01
08: 10Hz     0x05    0x01
09: 15Hz     0x3E    0x00
0A: 20Hz     0x36    0x00
0B: 50Hz     0x22    0x00
0C: 100Hz    0x19    0x00
0D: 200Hz    0x12    0x00
0E: 300Hz    0x0F    0x00
0F: 500Hz    0x0D    0x00

  ADC_OPT    ADCB    MUXB
0: 120kS/s   0x20    0x28
1: 140kS/s   0x10    0x28
2: 175KS/s   0x08    0x28
3: 220kS/s   0x08    0x20
4: 280kS/s   0x08    0x1A
5: 350kS/s   0x04    0x12
6: 440kS/s   0x03    0x10
7: 525kS/s   0x03    0x07
8: 700kS/s   0x02    0x04
*/  

wire [71:0] cache_reg1 = 72'h02_03_03_04_08_08_08_10_20;
wire [71:0] cache_reg2 = 72'h04_07_10_12_1A_20_28_28_28;
wire [127:0] cache_reg8 = 128'h0B_11_16_21_03_0D_1B_01_2E_29_1E_06_2A_18_2C_26;
wire [127:0] cache_reg9 = 128'h00_00_00_00_01_01_01_02_02_03_05_09_0A_0D_11_1A;
wire [127:0] cache_regA = 128'h08_10_17_25_0D_19_2C_17_1E_24_2B_02_05_07_08_05;
wire [127:0] cache_regB = 128'h00_00_00_00_01_01_01_02_03_04_06_0B_0D_10_15_1F;
wire [127:0] cache_regC = 128'h0D_0F_12_19_22_36_3E_05_12_28_14_2A_08_2C_23_38;
wire [127:0] cache_regD = 128'h00_00_00_00_00_00_00_01_01_01_02_02_03_06_11_36;

assign reg00 = 8'b11011110;
assign reg01 = {2'b00, cache_reg1[8*cmd_mix0[7:4]+5 -: 6]};
assign reg02 = {2'b00, cache_reg2[8*cmd_mix0[7:4]+5 -: 6]};
assign reg03 = {6'b000_000, cmd_mix1[3:2]};
assign reg04 = cmd_reg4;
assign reg05 = cmd_reg5;
assign reg06 = cmd_reg6;
assign reg07 = cmd_reg7;
assign reg08 = {cmd_mix0[3], cache_reg8[8*cmd_filt[7:4]+6 -: 7]};
assign reg09 = {cmd_mix0[3], cache_reg9[8*cmd_filt[7:4]+6 -: 7]};
assign reg10 = {cmd_mix0[2], cache_regA[8*cmd_filt[7:4]+6 -: 7]};
assign reg11 = {cmd_mix0[2], cache_regB[8*cmd_filt[7:4]+6 -: 7]};
assign reg12 = {cmd_mix0[1], cache_regC[8*cmd_filt[3:0]+6 -: 7]};
assign reg13 = {cmd_mix0[1], cache_regD[8*cmd_filt[3:0]+6 -: 7]};
assign regap = 8'b1111_1111;
assign devid = cmd_mix1[7:4];
assign dev_grp = cmd_mix1[1];

endmodule