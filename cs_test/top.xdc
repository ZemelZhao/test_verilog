############## NET - IOSTANDARD #######################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
#############SPI Configurate Setting###################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
#################resetsetting##########################
############## lec define#########################
set_property IOSTANDARD LVCMOS33 [get_ports {lec[*]}]
set_property PACKAGE_PIN H16 [get_ports {lec[3]}]
set_property PACKAGE_PIN G16 [get_ports {lec[2]}]
set_property PACKAGE_PIN K15 [get_ports {lec[1]}]
set_property PACKAGE_PIN J15 [get_ports {lec[0]}]

############## led define#########################
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property PACKAGE_PIN V20 [get_ports {led[31]}]
set_property PACKAGE_PIN R18 [get_ports {led[30]}]
set_property PACKAGE_PIN T17 [get_ports {led[29]}]
set_property PACKAGE_PIN V18 [get_ports {led[28]}]
set_property PACKAGE_PIN V22 [get_ports {led[27]}]
set_property PACKAGE_PIN P21 [get_ports {led[26]}]
set_property PACKAGE_PIN AA22 [get_ports {led[25]}]
set_property PACKAGE_PIN AB20 [get_ports {led[24]}]
set_property PACKAGE_PIN U20 [get_ports {led[23]}]
set_property PACKAGE_PIN P17 [get_ports {led[22]}]
set_property PACKAGE_PIN R17 [get_ports {led[21]}]
set_property PACKAGE_PIN U19 [get_ports {led[20]}]
set_property PACKAGE_PIN W22 [get_ports {led[19]}]
set_property PACKAGE_PIN T22 [get_ports {led[18]}]
set_property PACKAGE_PIN P20 [get_ports {led[17]}]
set_property PACKAGE_PIN Y20 [get_ports {led[16]}]
set_property PACKAGE_PIN T20 [get_ports {led[15]}]
set_property PACKAGE_PIN Y21 [get_ports {led[14]}]
set_property PACKAGE_PIN R16 [get_ports {led[13]}]
set_property PACKAGE_PIN U18 [get_ports {led[12]}]
set_property PACKAGE_PIN V21 [get_ports {led[11]}]
set_property PACKAGE_PIN T21 [get_ports {led[10]}]
set_property PACKAGE_PIN N20 [get_ports {led[9]}]
set_property PACKAGE_PIN Y22 [get_ports {led[8]}]
set_property PACKAGE_PIN T19 [get_ports {led[7]}]
set_property PACKAGE_PIN W21 [get_ports {led[6]}]
set_property PACKAGE_PIN N15 [get_ports {led[5]}]
set_property PACKAGE_PIN U17 [get_ports {led[4]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN U22 [get_ports {led[2]}]
set_property PACKAGE_PIN P22 [get_ports {led[1]}]
set_property PACKAGE_PIN AB21 [get_ports {led[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports key[*]]
set_property PACKAGE_PIN AB19 [get_ports key[1]]
set_property PACKAGE_PIN AA21 [get_ports key[0]]

set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PACKAGE_PIN M15 [get_ports rst_n]

create_clock -period 20 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
set_property PACKAGE_PIN P15 [get_ports sys_clk]
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
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rgmii_rxc_IBUF]