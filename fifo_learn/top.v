module top();
    wire clk;
    wire rst_n;

    wire rst;
    reg [2:0] dat;
    wire res;

    assign res = ~|dat;

    assign rst = ~rst_n;

    always@(posedge clk or posedge rst) begin
        if(rst) dat <= 3'h0;
        else dat <= dat + 1'b1;
    end

    clk_asm
    clk_asm_dut(
        .axi_clk_0(clk),
        .axi_rst_0_n(rst_n)
    );



endmodule