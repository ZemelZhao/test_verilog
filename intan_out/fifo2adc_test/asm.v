module asm();

    reg sclk, fclk, rstn;
    wire [7:0] state, adc_rxd, fifod_rxd;

    wire [63:0] sol0, sol1, sol2, sol3, sol4, sol5, sol6, sol7, sol8;
    wire [7:0] sos0, sos1, sos2, sos3, sos4, sos5, sos6, sos7, sos8;
    wire sob0, sob1, sob2, sob3, sob4, sob5, sob6, sob7, sob8;

    wire [63:0] intan_cmd, intan_ind, fifoi_grxd;
    wire [7:0] adc_state, intan_lrt, intan_end, flag_num;
    wire [7:0] hdat, flag_cmd, flag_ind;

    wire flag_lrt, flag_end, adc_rxen;
    wire flag_hrd, fs_fifo, fd_fifo;

    always begin
        sclk <= 1'b1;
        #8;
        sclk <= 1'b0;
        #8;
    end

    always begin
        fclk <= 1'b1;
        #5;
        fclk <= 1'b0;
        #5;
    end

    initial begin
        rstn <= 1'b1;
        #20;
        rstn <= 1'b0;
        #30;
        rstn <= 1'b1;
    end

    test
    test_dut(
        .clk(sclk),
        .fclk(fclk),
        .rst_n(rstn),
        .show_state(state),
        .show_adc_rxd(adc_rxd),
        .show_fifod_rxd(fifod_rxd),
        .sol0(intan_cmd),
        .sol1(intan_ind),
        .sol2(fifoi_grxd),
        .sol3(sol3),
        .sol4(sol4),
        .sol5(sol5),
        .sol6(sol6),
        .sol7(sol7),
        .sol8(sol8),
        .sos0(adc_state),
        .sos1(intan_lrt),
        .sos2(intan_end),
        .sos3(flag_num),
        .sos4(hdat),
        .sos5(flag_cmd),
        .sos6(flag_ind),
        .sos7(sos7),
        .sos8(sos8),
        .sob0(flag_lrt),
        .sob1(flag_end),
        .sob2(adc_rxen),
        .sob3(flag_hrd),
        .sob4(fs_fifo),
        .sob5(fd_fifo),
        .sob6(sob6),
        .sob7(sob7),
        .sob8(sob8)
    );


endmodule