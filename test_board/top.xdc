############## NET - IOSTANDARD #######################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
#############SPI Configurate Setting###################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
#################resetsetting##########################
# set_property IOSTANDARD LVCMOS15 [get_ports rst_n]
# set_property PACKAGE_PIN AB2 [get_ports rst_n]
############## ethernet define#########################
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property PACKAGE_PIN D16 [get_ports led[15]]
set_property PACKAGE_PIN C17 [get_ports led[14]]
set_property PACKAGE_PIN C15 [get_ports led[13]]
set_property PACKAGE_PIN C16 [get_ports led[12]]
set_property PACKAGE_PIN A20 [get_ports led[11]]
set_property PACKAGE_PIN B20 [get_ports led[10]]
set_property PACKAGE_PIN A19 [get_ports led[9]]
set_property PACKAGE_PIN A18 [get_ports led[8]]
set_property PACKAGE_PIN D21 [get_ports led[7]]
set_property PACKAGE_PIN C22 [get_ports led[6]]
set_property PACKAGE_PIN D20 [get_ports led[5]]
set_property PACKAGE_PIN C20 [get_ports led[4]]
set_property PACKAGE_PIN C19 [get_ports led[3]]
set_property PACKAGE_PIN B19 [get_ports led[2]]
set_property PACKAGE_PIN D18 [get_ports led[1]]
set_property PACKAGE_PIN C18 [get_ports led[0]]

set_property IOSTANDARD LVDS_25 [get_ports clk_p]
set_property IOSTANDARD LVDS_25 [get_ports clk_n]
set_property PACKAGE_PIN A16 [get_ports clk_p]
set_property PACKAGE_PIN A17 [get_ports clk_n]

set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

create_clock -period 8 [get_ports clk_p]
create_clock -period 8 [get_ports clk_n]




