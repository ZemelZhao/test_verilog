module test(
    input clk,

    input misop,
    output sclkp,
    output csp,
    output mosip,

    output [15:0] led_data
);

    (* MARK_DEBUG="true" *) wire sclk;
    (* MARK_DEBUG="true" *) wire cs;
    (* MARK_DEBUG="true" *) wire mosi;
    (* MARK_DEBUG="true" *) wire miso;
    wire rst;

    localparam CMD_CONCERT0 = 16'h0000;
    localparam CMD_CONCERTN = 16'h3F00;
    localparam CMD_CALIBRATE = 16'h5500;
    localparam CMD_CKEAR = 16'h6A00;
    localparam CMD_WRITE = 2'b10;
    localparam CMD_READ = 2'b11;

    localparam RET_WRITE = 8'hFF, RET_READ = 8'h00;

    localparam REG00 = 6'h00, REG01 = 6'h01, REG02 = 6'h02, REG03 = 6'h03;
    localparam REG04 = 6'h04, REG05 = 6'h05, REG06 = 6'h06, REG07 = 6'h07;
    localparam REG08 = 6'h08, REG09 = 6'h09, REG10 = 6'h0A, REG11 = 6'h0B;
    localparam REG12 = 6'h0C, REG13 = 6'h0D, REG14 = 6'h0E, REG15 = 6'h0F;
    localparam REG16 = 6'h10, REG17 = 6'h11, REG18 = 6'h12, REG19 = 6'h13;
    localparam REG20 = 6'h14, REG21 = 6'h15, REG40 = 6'h28, REG41 = 6'h29;
    localparam REG42 = 6'h2A, REG43 = 6'h2B, REG44 = 6'h2C, REG59 = 6'h3B;
    localparam REG60 = 6'h3C, REG61 = 6'h3D, REG62 = 6'h3E, REG63 = 6'h3F;

    (* MARK_DEBUG="true" *) wire [15:0] chip_txd;
    (* MARK_DEBUG="true" *) wire [15:0] chip_rxd0; 
    (* MARK_DEBUG="true" *) wire [15:0] chip_rxd1;

    (* MARK_DEBUG="true" *) reg [7:0] state; 

    localparam NUM = 32'd50_000_000;

    reg [31:0] num;
    reg judge;

    reg [7:0] next_state;
    wire fd_spi, fd_prd;
    wire spi_mc;
    wire fs;

    localparam IDLE = 8'h00, PREP = 8'h01, START = 8'h02, WAIT = 8'h03;
    localparam PRE0 = 8'h04, PRE1 = 8'h05;


    assign chip_txd = judge ?{CMD_WRITE, REG03, 8'h01} :{CMD_WRITE, REG03, 8'h00};

    assign led_data = ~chip_rxd0;
    assign fs = (state == START);

    assign miso = misop;
    assign sclkp = sclk;
    assign csp = cs;
    assign mosip = mosi;


    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                next_state <= PREP;
            end
            PREP: begin
                if(judge) next_state <= PRE0;
                else next_state <= PRE1;
            end
            PRE0: begin
                next_state <= START;
            end
            PRE1: begin
                next_state <= START;
            end
            START: begin
                if(fd_spi) next_state <= WAIT;
                else next_state <= START;
            end
            WAIT: begin
                if(fd_prd) next_state <= PREP;
                else next_state <= WAIT;
            end
        endcase
    end

    always @(posedge clk) begin
        if (state == IDLE) begin
            num <= 32'h0;
            judge <= 1'b1;
        end
        else if(num <= NUM) begin
            num <= num + 1'b1;
            judge <= judge;
        end
        else begin
            num <= 32'h0;
            judge <= ~judge;
        end
    end


    spi
    spi_dut(
        .clk(spi_mc),
        .rst(rst),

        .fs(fs),
        .fd_spi(fd_spi),
        .fd_prd(fd_prd),

        .miso(miso),
        .mosi(mosi),
        .cs(cs),
        .sclk(sclk),

        .chip_txd(chip_txd),
        .chip_rxd0(chip_rxd0),
        .chip_rxd1(chip_rxd1)
    );

    clkp
    clkp_dut(
        .clk_in1(clk),
        .clk_out1(spi_mc),
        .reset(rst)
    );

    // IBUFDS 
    // miso_dut(
    //     .O(miso),
    //     .I(misop),
    //     .IB(mison)
    // );

    // OBUFDS
    // sclk_dut(
    //     .O(sclkp),
    //     .OB(sclkn),
    //     .I(sclk)
    // );

    // OBUFDS 
    // cs_dut(
    //     .O(csp),
    //     .OB(csn),
    //     .I(cs)
    // );

    // OBUFDS 
    // mosi_dut(
    //     .O(mosip),
    //     .OB(mosin),
    //     .I(mosi)
    // );



endmodule