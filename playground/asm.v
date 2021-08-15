module asm();

    reg clk;
    reg [3:0] din0;
    reg [3:0] din1;
    wire [3:0] dout;


    top
    top_dut(
        .din0(din0),
        .din1(din1),
        .dout(dout)
    );

    always begin
        din1 <= 4'b1100;
        din0 <= 4'b0101;
        #5;
        din1 <= 4'b1010;
        din0 <= 4'b0101;
        #5;
        din1 <= 4'b1101;
        din0 <= 4'b0101;
        #5; 
    end



endmodule