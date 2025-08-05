module ps2_transceiver 
(
    inout ps2d, ps2c,
    input clk, reset,
    input write,
    input [7:0] data_in,
    output [7:0] data_out,
    output rx_done_tick, tx_done_tick
);

wire tx_idle;

ps2_receive ps2_rx
    (.clk(clk), .reset(reset), .data_out(data_out), .done_tick(rx_done_tick),
     .r_enable(tx_idle), .ps2d(ps2d), .ps2c(ps2c));

ps2_transmit ps2_tx
    (.clk(clk), .reset(reset), .data_in(data_in), .tx_finished(tx_done_tick),
     .w_enable(write), .ps2d(ps2d), .ps2c(ps2c), .tx_idle(tx_idle));


endmodule