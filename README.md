# Keyboard Interface
This is an interface for a USB keyboard written for the Basys-3 FPGA development board.

The Basys-3 includes both a USB-UART bridge for programming and general communication, as well as a USB-PS/2 bridge, which simulates a HID interface. This project communicates with the HID over the simulated PS/2 port, converts any received key codes to ASCII, handling key releases and capitalization internally, and transmits the ASCII code to the system over UART. A basic C file is included to allow the system interface with the board over the COM4 port.

The board will transmit codes to the keyboard over PS/2 to illuminate status LEDs (caps lock, scroll lock, and num lock). Included is a test bench to verify the functionality of the PS/2 transmission routine.

PS/2 Transceiver design is based on the implementation found in *FPGA Prototypign by Verilog Examples*, Pong P. Chu, 2008.
