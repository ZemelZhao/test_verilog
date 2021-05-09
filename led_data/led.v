module led(
    input sys_clk,
    input rst,

    input [7:0] data,

    output reg lec,
    output reg [3:0] led
);

    localparam NUM = 32'd25_000_000, ALL = 32'd50_000_000;
    reg [31:0] cnt;

    always @(posedge sys_clk or posedge rst) begin
        if(rst) begin
            lec <= 1'b1;
            led <= 4'h1;
        end
        else if(cnt < NUM) begin
            lec <= 1'b0;
            led <= ~data[7:4];
        end
        else if(cnt <= ALL) begin
            lec <= 1'b1;
            led <= ~data[3:0];
        end
        else begin
            lec <= lec;
            led <= led;
        end
    end

    always @(posedge sys_clk or posedge rst) begin
        if(rst) cnt <= 32'd0;
        else if(cnt < ALL) cnt <= cnt + 1'b1;
        else if(cnt >= ALL) cnt <= 32'h0;
        else cnt <= cnt;
    end


endmodule