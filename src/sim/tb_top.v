`timescale 1 ns/ 10 ps
module tb_top();

wire clk, reset;

wire drive_clk, drive_data;//Flags denoting whether vector generator is driving
wire stim_clk, stim_data;//Data driven by vector generator
wire ps2c, ps2d;
wire [7:0] w_data;
wire w_enable;

assign ps2c = drive_clk ? stim_clk : 1'bz;
assign ps2d = drive_data ? stim_data : 1'bz;

wire tx_finished, tx_idle;

vector_gen stimulus_unit
    (.clk(clk), .reset(reset), .data(w_data), .ps2c(ps2c), .ps2d(ps2d), .rx_clk(stim_clk), .rx_data(stim_data),
     .driving_c(drive_clk), .driving_d(drive_data), .tx_finished(tx_finished), .w_enable(w_enable));

ps2_transmit DUT
    (.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .w_enable(w_enable),
     .data_in(w_data), .tx_finished(tx_finished), .tx_idle(tx_idle));
     
monitor monitor_unit
    (.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .w_enable(w_enable));


endmodule