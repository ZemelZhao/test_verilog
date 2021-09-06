############## NET - IOSTANDARD #######################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
#############SPI Configurate Setting###################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
#################resetsetting##########################
############## lec define#########################

############## led define#########################
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property PACKAGE_PIN A18 [get_ports {led[15]}]
set_property PACKAGE_PIN A19 [get_ports {led[14]}]
set_property PACKAGE_PIN B20 [get_ports {led[13]}]
set_property PACKAGE_PIN A20 [get_ports {led[12]}]
set_property PACKAGE_PIN C16 [get_ports {led[11]}]
set_property PACKAGE_PIN C15 [get_ports {led[10]}]
set_property PACKAGE_PIN C17 [get_ports {led[9]}]
set_property PACKAGE_PIN D16 [get_ports {led[8]}]
set_property PACKAGE_PIN C18 [get_ports {led[7]}]
set_property PACKAGE_PIN D18 [get_ports {led[6]}]
set_property PACKAGE_PIN B19 [get_ports {led[5]}]
set_property PACKAGE_PIN C19 [get_ports {led[4]}]
set_property PACKAGE_PIN C20 [get_ports {led[3]}]
set_property PACKAGE_PIN D20 [get_ports {led[2]}]
set_property PACKAGE_PIN C22 [get_ports {led[1]}]
set_property PACKAGE_PIN D21 [get_ports {led[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports key]
set_property PACKAGE_PIN AB2 [get_ports key]

set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PACKAGE_PIN M15 [get_ports rst_n]

create_clock -period 20 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN P15 [get_ports clk]
############## ethernet define#########################
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[*]}]
set_property SLEW FAST [get_ports {rgmii_txd[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports e_mdc]
set_property IOSTANDARD LVCMOS33 [get_ports e_mdio]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_rxc]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_rxctl]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_txc]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_txctl]
set_property SLEW FAST [get_ports rgmii_txc]
set_property SLEW FAST [get_ports rgmii_txctl]

set_property PACKAGE_PIN G21 [get_ports {rgmii_rxd[3]}]
set_property PACKAGE_PIN F22 [get_ports {rgmii_rxd[2]}]
set_property PACKAGE_PIN F21 [get_ports {rgmii_rxd[1]}]
set_property PACKAGE_PIN E22 [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN E18 [get_ports {rgmii_txd[3]}]
set_property PACKAGE_PIN E17 [get_ports {rgmii_txd[2]}]
set_property PACKAGE_PIN D19 [get_ports {rgmii_txd[1]}]
set_property PACKAGE_PIN E19 [get_ports {rgmii_txd[0]}]
set_property PACKAGE_PIN E16 [get_ports e_mdc]
set_property PACKAGE_PIN G14 [get_ports e_mdio]

create_clock -period 8 [get_ports rgmii_rxc]
set_property PACKAGE_PIN G22 [get_ports rgmii_rxc]
set_property PACKAGE_PIN D22 [get_ports rgmii_rxctl]
set_property PACKAGE_PIN F19 [get_ports rgmii_txc]
set_property PACKAGE_PIN F20 [get_ports rgmii_txctl]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cs_dut/cs_clk_dut/clkf_eth_wiz/inst/clk_in1_clkf_eth]

set_false_path -from [get_clocks clk_out1_clkf_eth] -to [get_clocks clk_out1_clkf_sys]
set_false_path -from [get_clocks clk_out1_clkf_sys] -to [get_clocks clk_out1_clkf_eth]