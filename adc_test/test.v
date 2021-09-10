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
    wire fs_check;
    wire fd_check;

    reg [7:0] next_state;
    wire fd_spi, fd_prd;
    wire spi_mc;
    wire rst;
    wire fs;

    localparam IDLE = 8'h00, PREP = 8'h01, START = 8'h02, WAIT = 8'h03;
    localparam PRE0 = 8'h04, PRE1 = 8'h05;

    assign fs_check = (state == PREP);

    assign rst = ~rst_n;


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
                if(fd_check) next_state <= IDLE;
                else next_state <= PREP;
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
        .fd_check(fd_check)
    );


endmodule