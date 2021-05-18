module top(
    input sys_clk,
    input rst_n,
    input keyu,
    input keyd,
    output [3:0] lec,
    output [31:0] led
);

    wire fsu, fsd, fdu, fdd;
    wire [3:0] num;
    wire [7:0] reg00, reg01, reg02, reg03;
    wire [7:0] reg04, reg05, reg06, reg07;
    wire [7:0] reg08, reg09, reg0A, reg0B;
    wire [7:0] reg0C, reg0D, reg0E, reg0F;
    wire [7:0] reg10, reg11, reg12, reg13;
    wire [7:0] reg14, reg15, reg16, reg17;
    wire [7:0] reg18, reg19, reg1A, reg1B;
    wire [7:0] reg1C, reg1D, reg1E, reg1F;
    wire [7:0] reg20, reg21, reg22, reg23;
    wire [7:0] reg24, reg25, reg26, reg27;
    wire [7:0] reg28, reg29, reg2A, reg2B;
    wire [7:0] reg2C, reg2D, reg2E, reg2F;
    wire [7:0] reg30, reg31, reg32, reg33;
    wire [7:0] reg34, reg35, reg36, reg37;
    wire [7:0] reg38, reg39, reg3A, reg3B;
    wire [7:0] reg3C, reg3D, reg3E, reg3F;

    assign num = 4'hF;
    assign reg00 = 8'h00;
    assign reg01 = 8'h02;
    assign reg02 = 8'h04;
    assign reg03 = 8'h06;
    assign reg04 = 8'h11;
    assign reg05 = 8'h13;
    assign reg06 = 8'h15;
    assign reg07 = 8'h17;
    assign reg08 = 8'h20;
    assign reg09 = 8'h22;
    assign reg0A = 8'h24;
    assign reg0B = 8'h26;
    assign reg0C = 8'h31;
    assign reg0D = 8'h33;
    assign reg0E = 8'h35;
    assign reg0F = 8'h37;
    assign reg10 = 8'h48;
    assign reg11 = 8'h4A;
    assign reg12 = 8'h4C;
    assign reg13 = 8'h4E;
    assign reg14 = 8'h59;
    assign reg15 = 8'h5B;
    assign reg16 = 8'h5D;
    assign reg17 = 8'h5F;
    assign reg18 = 8'h68;
    assign reg19 = 8'h6A;
    assign reg1A = 8'h6C;
    assign reg1B = 8'h6E;
    assign reg1C = 8'h79;
    assign reg1D = 8'h7B;
    assign reg1E = 8'h7D;
    assign reg1F = 8'h7F;
    assign reg20 = 8'h80;
    assign reg21 = 8'h82;
    assign reg22 = 8'h84;
    assign reg23 = 8'h86;
    assign reg24 = 8'h91;
    assign reg25 = 8'h93;
    assign reg26 = 8'h95;
    assign reg27 = 8'h97;
    assign reg28 = 8'hA0;
    assign reg29 = 8'hA2;
    assign reg2A = 8'hA4;
    assign reg2B = 8'hA6;
    assign reg2C = 8'hB1;
    assign reg2D = 8'hB3;
    assign reg2E = 8'hB5;
    assign reg2F = 8'hB7;
    assign reg30 = 8'hC8;
    assign reg31 = 8'hCA;
    assign reg32 = 8'hCC;
    assign reg33 = 8'hCE;
    assign reg34 = 8'hD9;
    assign reg35 = 8'hDB;
    assign reg36 = 8'hDD;
    assign reg37 = 8'hDF;
    assign reg38 = 8'hE8;
    assign reg39 = 8'hEA;
    assign reg3A = 8'hEC;
    assign reg3B = 8'hEE;
    assign reg3C = 8'hF9;
    assign reg3D = 8'hFB;
    assign reg3E = 8'hFD;
    assign reg3F = 8'hFF;
    


    key 
    key_dut0(
        .clk(sys_clk),
        .key(keyu),
        .fs(fsu),
        .fd(fdu)
    );

    key 
    key_dut1(
        .clk(sys_clk),
        .key(keyd),
        .fs(fsd),
        .fd(fdd)
    );

    led 
    led_dut (
        .clk(sys_clk),
        .rst(~rst_n),
        .num(num),
        .lec(lec),
        .led(led),
        .fsu(fsu),
        .fsd(fsd),
        .fdu(fdu),
        .fdd(fdd),
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
        .reg0A(reg0A),
        .reg0B(reg0B),
        .reg0C(reg0C),
        .reg0D(reg0D),
        .reg0E(reg0E),
        .reg0F(reg0F),
        .reg10(reg10),
        .reg11(reg11),
        .reg12(reg12),
        .reg13(reg13),
        .reg14(reg14),
        .reg15(reg15),
        .reg16(reg16),
        .reg17(reg17),
        .reg18(reg18),
        .reg19(reg19),
        .reg1A(reg1A),
        .reg1B(reg1B),
        .reg1C(reg1C),
        .reg1D(reg1D),
        .reg1E(reg1E),
        .reg1F(reg1F),
        .reg20(reg20),
        .reg21(reg21),
        .reg22(reg22),
        .reg23(reg23),
        .reg24(reg24),
        .reg25(reg25),
        .reg26(reg26),
        .reg27(reg27),
        .reg28(reg28),
        .reg29(reg29),
        .reg2A(reg2A),
        .reg2B(reg2B),
        .reg2C(reg2C),
        .reg2D(reg2D),
        .reg2E(reg2E),
        .reg2F(reg2F),
        .reg30(reg30),
        .reg31(reg31),
        .reg32(reg32),
        .reg33(reg33),
        .reg34(reg34),
        .reg35(reg35),
        .reg36(reg36),
        .reg37(reg37),
        .reg38(reg38),
        .reg39(reg39),
        .reg3A(reg3A),
        .reg3B(reg3B),
        .reg3C(reg3C),
        .reg3D(reg3D),
        .reg3E(reg3E),
        .reg3F(reg3F)
    );



endmodule