module cs(
    input sys_clk,

    output reg fs_fifowrite,
    input fd_fifowrite,

    output reg fs_fifod2mac,
    input fd_fifod2mac,
    
    input rst,
    output reg [7:0] din
);

    localparam CNT = 32'd50_000_000;
    reg [31:0] cnt;

    always@(posedge sys_clk or posedge rst) begin
        if(rst) cnt <= 32'h0;
        else if(cnt >= CNT) cnt <= 32'h0;
        else cnt <= cnt + 1'b1;
    end

    always@(posedge sys_clk or posedge rst) begin
        if(rst) din <= 8'h0;
        else if(cnt == CNT) din <= din + 1'b1;
        else din <= din;
    end

    always@(posedge sys_clk or posedge rst) begin
        if(rst) fs_fifowrite <= 1'b0;
        else if(cnt == CNT) fs_fifowrite <= 1'b1;
        else if(fd_fifowrite) fs_fifowrite <= 1'b0;
        else fs_fifowrite <= fs_fifowrite;
    end

    always@(posedge sys_clk or posedge rst) begin
        if(rst) fs_fifod2mac <= 1'b0;
        else if(fd_fifowrite) fs_fifod2mac <= 1'b1;
        else if(fd_fifod2mac) fs_fifod2mac <= 1'b0;
        else fs_fifod2mac <= fs_fifod2mac;
    end


endmodule