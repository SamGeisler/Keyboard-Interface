set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
set_property PACKAGE_PIN W5 [get_ports i_clk]
create_clock -name sysclk -period 10 [get_ports i_clk]

set_property IOSTANDARD LVCMOS33 [get_ports i_TXD]
set_property PACKAGE_PIN B18 [get_ports i_TXD]

set_property IOSTANDARD LVCMOS33 [get_ports o_RXD]
set_property PACKAGE_PIN A18 [get_ports o_RXD]

set_property IOSTANDARD LVCMOS33 [get_ports io_PS2_clk]
set_property PACKAGE_PIN C17 [get_ports io_PS2_clk]
set_property PULLTYPE PULLUP [get_ports io_PS2_clk]

set_property IOSTANDARD LVCMOS33 [get_ports io_PS2_data]
set_property PACKAGE_PIN B17 [get_ports io_PS2_data]
set_property PULLTYPE PULLUP [get_ports io_PS2_data]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led1[0]}]
set_property PACKAGE_PIN U16 [get_ports {o_db_led1[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led1[1]}]
set_property PACKAGE_PIN E19 [get_ports {o_db_led1[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led1[2]}]
set_property PACKAGE_PIN U19 [get_ports {o_db_led1[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led1[3]}]
set_property PACKAGE_PIN V19 [get_ports {o_db_led1[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led2[0]}]
set_property PACKAGE_PIN W18 [get_ports {o_db_led2[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led2[1]}]
set_property PACKAGE_PIN U15 [get_ports {o_db_led2[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led2[2]}]
set_property PACKAGE_PIN U14 [get_ports {o_db_led2[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led2[3]}]
set_property PACKAGE_PIN V15 [get_ports {o_db_led2[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led3[0]}]
set_property PACKAGE_PIN V13 [get_ports {o_db_led3[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led3[1]}]
set_property PACKAGE_PIN V3 [get_ports {o_db_led3[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led3[2]}]
set_property PACKAGE_PIN W3 [get_ports {o_db_led3[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led3[3]}]
set_property PACKAGE_PIN U3 [get_ports {o_db_led3[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led4[0]}]
set_property PACKAGE_PIN P3 [get_ports {o_db_led4[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led4[1]}]
set_property PACKAGE_PIN N3 [get_ports {o_db_led4[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led4[2]}]
set_property PACKAGE_PIN P1 [get_ports {o_db_led4[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_db_led4[3]}]
set_property PACKAGE_PIN L1 [get_ports {o_db_led4[3]}]