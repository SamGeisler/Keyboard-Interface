module top (input i_clk, input i_TXD, inout io_PS2_clk, inout io_PS2_data,
output o_RXD);

wire [7:0] w_char;
wire [2:0] w_led_status;
wire w_ready;

kb_interface KB_inst(.i_clk(i_clk), .io_PS2_clk(io_PS2_clk), .io_PS2_data(io_PS2_data), .o_keycode(w_char), .o_ready(w_ready), .i_led_status(w_led_status));

UART_transmit UART_inst(.i_clk(i_clk), .i_TXD(i_TXD), .i_send(w_ready), .i_to_send(w_char), .o_RXD(o_RXD), .o_led_status(w_led_status));


endmodule