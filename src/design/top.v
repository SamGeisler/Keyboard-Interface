module top 
(
    inout ps2d, ps2c,
    input clk, reset,
    input UART_txd,
    output UART_rxd
);

wire [2:0] led_status;
wire [7:0] UART_tx_data;
wire UART_tx_tick;

kb_interface kb_interface_unit
    (.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .led_status(led_status),
     .UART_tx_data(UART_tx_data), .UART_tx_tick(UART_tx_tick));

UART_transmit UART_transmit_unit
    (.i_clk(clk), .i_TXD(UART_txd), .o_RXD(UART_rxd), .o_led_status(led_status),
     .i_send(UART_tx_tick), .i_to_send(UART_tx_data));


endmodule