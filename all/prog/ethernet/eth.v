module eth(
    output e_mdc,                           //phy emdio clock
    inout e_mdio,                          //phy emdio data
    output[3:0] rgmii_txd,                       //phy data send
    output rgmii_txctl,                     //phy data send control
    output rgmii_txc,                       //Clock for sending data
    input[3:0] rgmii_rxd,                       //recieve data
    input rgmii_rxctl,                     //Control signal for receiving data
    input rgmii_rxc,
    output gmii_txc,
    input gmii_rxc,
    output gmii_rxdv,
    output [7:0] gmii_rxd,
    input gmii_txen,
    input [7:0] gmii_txd
);             

    wire                gmii_tx_er;              //gmii send clock
    wire                gmii_crs;
    wire                gmii_col;                  
    wire                gmii_rx_er;
    wire  [ 1:0]        speed_selection;                // 1x gigabit, 01 100Mbps, 00 10mbps
    wire                duplex_mode;                    // 1 full, 0 half
    assign speed_selection = 2'b10;
    assign duplex_mode = 1'b1;

    miim_top 
    miim_top_dut(
        .reset_i            (1'b0),
        .miim_clock_i       (gmii_txc),
        .mdc_o              (e_mdc),
        .mdio_io            (e_mdio),
        .link_up_o          (),                  //link status
        .speed_o            (),                  //link speed
        .speed_override_i   (2'b11)              //11: autonegoation
    );
	
/*************************************************************************
GMII and RGMII data conversion
****************************************************************************/
    util_gmii_to_rgmii 
    util_gmii_to_rgmii_dut(
        .reset(1'b0),
        .rgmii_td(rgmii_txd),
        .rgmii_tx_ctl(rgmii_txctl),
        .rgmii_txc(rgmii_txc),
        .rgmii_rd(rgmii_rxd),
        .rgmii_rx_ctl(rgmii_rxctl),
        .gmii_rx_clk(gmii_rxc),
        .gmii_txd(gmii_txd),
        .gmii_tx_en(gmii_txen),
        .gmii_tx_er(1'b0),
        .gmii_tx_clk(gmii_txc),
        .gmii_crs(gmii_crs),
        .gmii_col(gmii_col),
        .gmii_rxd(gmii_rxd),
        .rgmii_rxc(rgmii_rxc),//add
        .gmii_rx_dv(gmii_rxdv),
        .gmii_rx_er(gmii_rx_er),
        .speed_selection(speed_selection),
        .duplex_mode(duplex_mode)
    );

endmodule