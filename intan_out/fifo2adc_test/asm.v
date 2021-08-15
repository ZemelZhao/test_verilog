module asm();

    reg sclk, fclk, rstn;
    wire [7:0] state, adc_rxd, fifod_rxd;

    wire [7:0] state_adct_intan0;

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
        .state_adct_intan0(state_adct_intan0)
    );


endmodule