module top(
    input sys_clk,
    input rst_n,
    
    input [1:0] key,
    
    output [3:0] lec,
    output [31:0] led
);

    wire [3:0] num;
    wire fsu, fdu, fsd, fdd;

    wire [7:0] reg00, reg01, reg02, reg03;
    wire [7:0] reg04, reg05, reg06, reg07;
    wire [7:0] reg08, reg09, reg0A, reg0B;
    wire [7:0] reg0C, reg0D, reg0E, reg0F;

    assign reg00 = 8'h55;
    assign reg01 = 8'hAA;
    assign reg02 = 8'h12;
    assign reg03 = 8'hEF;
    assign reg04 = 8'h23;
    assign reg05 = 8'hDE;
    assign reg06 = 8'h34;
    assign reg07 = 8'hCD;
    assign reg08 = 8'h45;
    assign reg09 = 8'hBC;
    assign reg0A = 8'h56;
    assign reg0B = 8'hAB;
    assign reg0C = 8'h67;
    assign reg0D = 8'h9A;
    assign reg0E = 8'h78;
    assign reg0F = 8'h89;

    assign num = 4'h3;

    led
    led_dut(
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
        .reg0F(reg0F)
    );

    key 
    key_dutu(
        .clk(sys_clk),
        .key(key[1]),
        .fs(fsu),
        .fd(fdu)
    );

    key 
    key_dutd(
        .clk(sys_clk),
        .key(key[0]),
        .fs(fsd),
        .fd(fdd)
    );

endmodule