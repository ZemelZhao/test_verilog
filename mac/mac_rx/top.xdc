############## NET - IOSTANDARD #######################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
#############SPI Configurate Setting###################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
################# CLock Setting #######################
create_clock -period 20 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
set_property PACKAGE_PIN P15 [get_ports sys_clk]
#################resetsetting##########################
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PACKAGE_PIN M15 [get_ports rst_n]
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

set_property IOSTANDARD LVCMOS33 [get_ports led[*]]
set_property PACKAGE_PIN H16 [get_ports led[3]]
set_property PACKAGE_PIN G16 [get_ports led[2]]
set_property PACKAGE_PIN K15 [get_ports led[1]]
set_property PACKAGE_PIN J15 [get_ports led[0]]

set_property IOSTANDARD LVCMOS33 [get_ports lec]
set_property PACKAGE_PIN G15 [get_ports lec]