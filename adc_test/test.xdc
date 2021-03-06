############## NET - IOSTANDARD #######################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
#############SPI Configurate Setting###################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
############## led define#########################
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property PACKAGE_PIN A18 [get_ports {led[11]}]
set_property PACKAGE_PIN A19 [get_ports {led[10]}]
set_property PACKAGE_PIN B20 [get_ports {led[9]}]
set_property PACKAGE_PIN A20 [get_ports {led[8]}]
set_property PACKAGE_PIN C16 [get_ports {led[7]}]
set_property PACKAGE_PIN C15 [get_ports {led[6]}]
set_property PACKAGE_PIN C17 [get_ports {led[5]}]
set_property PACKAGE_PIN D16 [get_ports {led[4]}]
set_property PACKAGE_PIN C18 [get_ports {led[3]}]
set_property PACKAGE_PIN D18 [get_ports {led[2]}]
set_property PACKAGE_PIN B19 [get_ports {led[1]}]
set_property PACKAGE_PIN C19 [get_ports {led[0]}]
# set_property PACKAGE_PIN C20 [get_ports {led[3]}]
# set_property PACKAGE_PIN D20 [get_ports {led[2]}]
# set_property PACKAGE_PIN C22 [get_ports {led[1]}]
# set_property PACKAGE_PIN D21 [get_ports {led[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led_adc}]
set_property PACKAGE_PIN G15 [get_ports {led_adc}]

set_property 




create_clock -period 20 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN P15 [get_ports clk]
############## ethernet define#########################