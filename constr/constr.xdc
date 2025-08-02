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