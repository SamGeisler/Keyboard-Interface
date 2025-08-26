`timescale 1 ns/ 100 ps
module tb_top();

wire clk, reset;

wire drive_clk, drive_data;//Flags denoting whether vector generator is driving
wire stim_clk, stim_data;//Data driven by vector generator
wire ps2c, ps2d;
wire [7:0] tx_data;
wire [7:0] rx_data;
wire w_enable;
wire tx_done_tick, rx_done_tick;

assign ps2c = drive_clk ? stim_clk : 1'bz;
assign ps2d = drive_data ? stim_data : 1'bz;

pullup(ps2d);
pullup(ps2c);

wire rx_done_tick, tx_done_tick;

vector_gen stimulus_unit
    (.clk(clk), .reset(reset), .data(tx_data), .ps2c(ps2c), .ps2d(ps2d), .rx_clk(stim_clk), .rx_data(stim_data),
     .driving_c(drive_clk), .driving_d(drive_data), .w_enable(w_enable), .tx_done_tick(tx_done_tick));

ps2_transceiver UUT
    (.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .write(w_enable),
     .data_in(tx_data), .data_out(rx_data),
     .tx_done_tick(tx_done_tick), .rx_done_tick(rx_done_tick));
     
monitor monitor_unit
    (.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .w_enable(w_enable),
     .rx_done_tick(rx_done_tick), .rx_data(rx_data));


endmodule