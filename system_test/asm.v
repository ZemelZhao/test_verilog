module asm();

    reg gmii_txc, gmii_rxc, sys_clk, fifo_clk;
    reg rst;
    wire [63:0] sol0, sol1, sol2, sol3, sol4, sol5, sol6, sol7;
    wire [63:0] sol8, sol9, solA, solB, solC, solD, solE, solF;
    wire [7:0] sos0, sos1, sos2, sos3, sos4, sos5, sos6, sos7;
    wire [7:0] sos8, sos9, sosA, sosB, sosC, sosD, sosE, sosF;
    wire sob0, sob1, sob2, sob3, sob4, sob5, sob6, sob7;
    wire sob8, sob9, sobA, sobB, sobC, sobD, sobE, sobF;


    always begin
        gmii_txc <= 1'b0;
        #8;
        gmii_txc <= 1'b1;
        #8;
    end

    always begin
        gmii_rxc <= 1'b0;
        #8;
        gmii_rxc <= 1'b1;
        #8;
    end

    always begin
        sys_clk <= 1'b0;
        #20;
        sys_clk <= 1'b1;
        #20;
    end

    always begin
        fifo_clk <= 1'b0;
        #10;
        fifo_clk <= 1'b1;
        #10;
    end

    initial begin
        rst <= 1'b0;
        #80;
        rst <= 1'b1;
        #100;
        rst <= 1'b0;
    end

    test 
    test_dut(
        .gmii_txc(gmii_txc),
        .gmii_rxc(gmii_rxc),
        .sys_clk(sys_clk),
        .fifo_clk(fifo_clk),
        .rst(rst),
        .sol0(sol0),
        .sol1(sol1),
        .sol2(sol2),
        .sol3(sol3),
        .sol4(sol4),
        .sol5(sol5),
        .sol6(sol6),
        .sol7(sol7),
        .sol8(sol8),
        .sol9(sol9),
        .solA(solA),
        .solB(solB),
        .solC(solC),
        .solD(solD),
        .solE(solE),
        .solF(solF),
        .sos0(sos0),
        .sos1(sos1),
        .sos2(sos2),
        .sos3(sos3),
        .sos4(sos4),
        .sos5(sos5),
        .sos6(sos6),
        .sos7(sos7),
        .sos8(sos8),
        .sos9(sos9),
        .sosA(sosA),
        .sosB(sosB),
        .sosC(sosC),
        .sosD(sosD),
        .sosE(sosE),
        .sosF(sosF),
        .sob0(sob0),
        .sob1(sob1),
        .sob2(sob2),
        .sob3(sob3),
        .sob4(sob4),
        .sob5(sob5),
        .sob6(sob6),
        .sob7(sob7),
        .sob8(sob8),
        .sob9(sob9),
        .sobA(sobA),
        .sobB(sobB),
        .sobC(sobC),
        .sobD(sobD),
        .sobE(sobE),
        .sobF(sobF)
    );



endmodule