set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN W5 [get_ports clk]
create_clock -name sysclk -period 10 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PACKAGE_PIN T18 [get_ports reset]

set_property IOSTANDARD LVCMOS33 [get_ports UARX_txd]
set_property PACKAGE_PIN B18 [get_ports UARX_txd]

set_property IOSTANDARD LVCMOS33 [get_ports UART_rxd]
set_property PACKAGE_PIN A18 [get_ports UART_rxd]

set_property IOSTANDARD LVCMOS33 [get_ports ps2c]
set_property PACKAGE_PIN C17 [get_ports ps2c]
set_property PULLTYPE PULLUP [get_ports ps2c]

set_property IOSTANDARD LVCMOS33 [get_ports ps2d]
set_property PACKAGE_PIN B17 [get_ports ps2d]
set_property PULLTYPE PULLUP [get_ports ps2d]