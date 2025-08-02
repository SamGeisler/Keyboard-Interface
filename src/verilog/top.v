module top (input i_clk, input i_TXD, inout io_PS2_clk, inout io_PS2_data,
output o_RXD, output [3:0] o_db_led1, output [3:0] o_db_led2, output [3:0] o_db_led3, output [3:0] o_db_led4);

wire [8:0] w_keycode;
wire [2:0] w_led_status;
wire w_ready;

kb_interface KB_inst(.i_clk(i_clk), .io_PS2_clk(io_PS2_clk), .io_PS2_data(io_PS2_data), .o_keycode(w_keycode), .o_ready(w_ready), .i_led_status(w_led_status), .o_db_led1(o_db_led1), .o_db_led2(o_db_led2), .o_db_led3(o_db_led3), .o_db_led4(o_db_led4));

UART_transmit UART_inst(.i_clk(i_clk), .i_TXD(i_TXD), .i_send(w_ready), .i_to_send(w_keycode[8:1]), .o_RXD(o_RXD), .o_led_status(w_led_status));


endmodule