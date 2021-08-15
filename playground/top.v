module top(
    input[3:0] din0,
    input [3:0] din1,
    output [3:0] dout
);

    assign dout = &(din1 | din0);



endmodule