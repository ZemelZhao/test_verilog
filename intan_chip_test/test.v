module test(
    input clk,
    output [15:0] led
);
    assign led = ~led_show;

    reg [16:0] led_show;

    localparam CNT = 32'd50_000_000;
    reg [31:0] num_cnt;
    reg [7:0] state, next_state;
    localparam ID00 = 8'h00, IW00 = 8'h01;
    localparam ID01 = 8'h02, IW01 = 8'h03;
    localparam IDLE = 8'h10;


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
        if(state == ID00) led_show <= 16'h55AA;
        else if(state == ID01) led_show <= 16'h789A;
        else led_show <= led_show;
    end





endmodule