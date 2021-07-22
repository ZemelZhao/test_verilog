module top(
    input clk,
    output [15:0] led
);

    assign led = ~led_show;

	reg [15:0] led_show;

    reg [31:0] cnt;
    localparam WAIT = 4'h0, CHANGE = 4'h1;
    reg [3:0] state;


    always@(posedge clk) begin
        case(state)
            WAIT: begin
                if(cnt >= 32'd50_000_000) state <= CHANGE;
                else state <= WAIT;
            end
            CHANGE: begin
                state <= WAIT;
                case(led_show)
                    16'h8001: led_show <= 16'h4002;
                    16'h4002: led_show <= 16'h2004;
                    16'h2004: led_show <= 16'h1008;
                    16'h1008: led_show <= 16'h0810;
                    16'h0810: led_show <= 16'h0420;
                    16'h0420: led_show <= 16'h0240;
                    16'h0240: led_show <= 16'h0180;
                    16'h0180: led_show <= 16'h8001;
                    default: led_show <= 16'h8001;
                endcase
            end
            default: state <= WAIT;
        endcase
    end

    always @(posedge clk) begin
        if(state == CHANGE) cnt <= 32'h0;
        else if(state == WAIT) cnt <= cnt + 1'b1;
        else cnt <= cnt;
    end



endmodule