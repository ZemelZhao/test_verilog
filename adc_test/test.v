module test(
    input clk,
    input rst_n,

    (* MARK_DEBUG="true" *) input misop,
    (* MARK_DEBUG="true" *) output sclkp,
    (* MARK_DEBUG="true" *) output csp,
    (* MARK_DEBUG="true" *) output mosip,

    output [15:0] led_data
);


    (* MARK_DEBUG="true" *) reg [7:0] state; 

    localparam NUM = 32'd50_000_000;

    reg [31:0] num;
    reg judge;

    wire [1:0] dev_kind;
    wire fs_check, fs_conf;
    wire fd_check, fd_conf;

    wire [7:0] reg00, reg01, reg02, reg03;
    wire [7:0] reg04, reg05, reg06, reg07;
    wire [7:0] reg08, reg09, reg10, reg11;
    wire [7:0] reg12, reg13, regap;

    wire [7:0] eth_cmd0, eth_cmd1, eth_cmd2;
    wire [7:0] eth_cmd3, eth_cmd4, eth_cmd5;
    wire [7:0] eth_cmd6, eth_cmd7, eth_cmd8;

    wire [1:0] temps, zchk_scale;
    wire [7:0] zchk_adc;
    wire [7:0] info_sr;

    wire [3:0] dev_id;
    wire dev_grp;

    reg [7:0] next_state;
    wire fd_spi, fd_prd;
    wire spi_mc;
    wire rst;
    wire fs;

    localparam IDLE = 8'h00, CHECK = 8'h01, CONF = 8'h02, WAIT = 8'h03;
    localparam PRE0 = 8'h04, PRE1 = 8'h05;

    assign fs_check = (state == CHECK);
    assign fs_conf = (state == CONF);

    assign eth_cmd0 = 8'b00_00_11_00;
    assign eth_cmd1 = 8'hFA;
    assign eth_cmd2 = 8'h95;
    assign eth_cmd3 = 8'h80;
    assign eth_cmd4 = 8'h35;
    assign eth_cmd5 = 8'h00;
    assign eth_cmd6 = 8'h00;
    assign eth_cmd7 = 8'h00;
    assign eth_cmd8 = 8'h79;
    assign temps = 2'b00;
    assign zchk_scale = 2'b00;
    assign zchk_adc = 8'h00;

    assign rst = ~rst_n;


    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                next_state <= CHECK;
            end
            CHECK: begin
                if(fd_check) next_state <= CONF;
                else next_state <= CHECK;
            end
            CONF: begin
                if(fd_conf) next_state <= IDLE;
                else next_state <= CONF;
            end
        endcase
    end

    // always @(posedge clk) begin
    //     if (state == IDLE) begin
    //         num <= 32'h0;
    //         judge <= 1'b1;
    //     end
    //     else if(num <= NUM) begin
    //         num <= num + 1'b1;
    //         judge <= judge;
    //     end
    //     else begin
    //         num <= 32'h0;
    //         judge <= ~judge;
    //     end
    // end



    clkp
    clkp_dut(
        .clk_in1(clk),
        .clk_out1(spi_mc),
        .reset(rst)
    );

    intan
    intan_dut(
        .clk(clk),
        .rst(rst),

        .spi_mc(spi_mc),
        .miso(misop),
        .cs(csp),
        .mosi(mosip),
        .sclk(sclkp),
        .dev_kind(dev_kind),

        .fs_check(fs_check),
        .fs_conf(fs_conf),
        .fd_check(fd_check),
        .fd_conf(fd_conf),

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
        .regap(regap)
    );

    cs_reg 
    cs_reg_dut(
        .eth_cmd0(eth_cmd0),
        .eth_cmd1(eth_cmd1),
        .eth_cmd2(eth_cmd2),
        .eth_cmd3(eth_cmd3),
        .eth_cmd4(eth_cmd4),
        .eth_cmd5(eth_cmd5),
        .eth_cmd6(eth_cmd6),
        .eth_cmd7(eth_cmd7),
        .eth_cmd8(eth_cmd8),
        .temps(temps),
        .zchk_adc(zchk_adc),
        .zchk_scale(zchk_scale),
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
        .dev_id(dev_id),
        .dev_grp(dev_grp),
        .dev_kind(),
        .info_sr(info_sr)
    );



endmodule