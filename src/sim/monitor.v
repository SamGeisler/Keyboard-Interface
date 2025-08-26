`timescale 1 ns/ 10 ps
module monitor(
    input clk, reset,
    input ps2c, ps2d,
    input w_enable,
    input rx_done_tick,
    input [7:0] rx_data
);

reg [31:0] cp0;

integer i;
        
initial begin
    $display("\nVerifying reception functionality (sending \"Test reception 1.\" over PS/2 line for reception by UUT):");
    repeat(17) get_char_rx(1);
    
    $write("\n");

    $display("Verifying transmission functionality (sending \"Test transmission 1.\" directly to UUT for transmission):");
    repeat(20) get_char_tx(0,1);
    
    $write("\n");
    
    $display("\nVerifying reception functionality (sending \"Test reception 2.\" over PS/2 line for reception by UUT):");
    repeat(17) get_char_rx(1);
    
    $write("\n");

    $display("Verifying transmission functionality (sending \"Test transmission 2.\" directly to UUT for transmission):");
    repeat(20) get_char_tx(0,1);
    
    $write("\n");

end

reg [7:0] rx_word, tx_word;
reg parity;

task get_char_tx(input verbose, input echo); 
begin
    
    tx_word = 0;
    parity = 0;
    //Host (DUT) drives clock low
    @(negedge ps2c)
    cp0 = $time;
    if(verbose) $display("Host send request detected");

    //Host releases clock and drives data low
    @(negedge ps2d)
    if(verbose) $display("Start bit FE detected. Request time (us): %d", ($time - cp0)/1000);

    //Stimulus pulls clock high
    wait(ps2c === 1);

    //Data bits
    for( i = 0; i<8; i = i + 1) begin
        @(posedge ps2c)
        tx_word[i] = ps2d;
        if(verbose) $display("Read value %d into bit %d", ps2d, i);
    end

    @(posedge ps2c)
    parity = ps2d;
    if(verbose)
        if(^{parity,tx_word})
            $display("Correct: Odd parity");
        else
            $display("Incorrect: Even parity");
    
    @(posedge ps2c)
    @(negedge ps2c)
    if(verbose)
        if(ps2d === 0)
            $display("Ack found");
        else
            $display("Found high data line where ack was expected");
        
    if(verbose) $display("Received character: %c", tx_word);

    if(echo) $write("%c",tx_word);
end
endtask

task get_char_rx(input echo); 
begin
    rx_word = 0;
    @(posedge rx_done_tick);
    rx_word = rx_data;

    if(echo) $write("%c", rx_word);

end
endtask


endmodule