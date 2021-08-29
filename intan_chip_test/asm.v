module asm();
    reg clk;
    wire [15:0] led;

    always begin
        clk <= 1'b1;
        #5;
        clk <= 1'b0;
        #5;
    end



    test
    test_dut(
        .clk(clk),
        .led(led)
    );

endmodule