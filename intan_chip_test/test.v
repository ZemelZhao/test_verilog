module test(
    input clkp,
    input clkn,
    output led
);
    wire clk;

    assign led = ~led_show;

    reg led_show;

    localparam CNT = 32'd200_000_000;
    reg [31:0] num_cnt;
    reg [7:0] state, next_state;
    localparam ID00 = 8'h00, IW00 = 8'h01;
    localparam ID01 = 8'h02, IW01 = 8'h03;
    localparam IDLE = 8'h10;

    IBUFDS
    clk_ibufds(
        .O(clk),
        .I(clkp),
        .IB(clkn)
    );


    always @(posedge clk) begin
        state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: next_state <= ID00;
            ID00: begin
                if(num_cnt >= CNT) next_state <= IW00;
                else next_state <= ID00;
            end
            IW00: next_state <= ID01;
            ID01: begin
                if(num_cnt >= CNT) next_state <= IW01;
                else next_state <= ID01;
            end
            IW01: next_state <= ID00;
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(state == ID00) num_cnt <= num_cnt + 1'b1;
        else if(state == ID01) num_cnt <= num_cnt + 1'b1;
        else num_cnt <= 32'h0;
    end

    always @(posedge clk) begin
        if(state == ID00) led_show <= 1'b1;
        else if(state == ID01) led_show <= 1'b0;
        else led_show <= led_show;
    end





endmodule