`timescale 1 ns/ 10 ps
module monitor(
    input clk, reset,
    input ps2c, ps2d,
    input w_enable
);

reg [31:0] cp0, cp1;

reg [7:0] word;
reg parity;

integer i;

always @*
    if(reset) begin
        word = 0;
        parity = 0;
    end
        

always@(posedge w_enable) begin
    //Host (DUT) drives clock low
    @(negedge ps2c)
    cp0 = $time;
    $display("Host send request dected");

    //Host releases clock and drives data low
    @(negedge ps2d)
    $display("Start bit FE detected. Request time (us): %d", ($time - cp0)/1000);

    //Device (stimulus) pulls clock high
    @(posedge ps2c);

    //Data bits
    for( i = 0; i<8; i = i + 1) begin
        @(posedge ps2c)
        word[i] = ps2d;
        $display("Read value %d into bit %d", ps2d, word[i]);
    end

    @(posedge ps2c)
    parity = ps2d;
    if(^{parity,word})
        $display("Correct: Odd parity");
    else
        $display("Incorrect: Even parity");
    
    @(posedge ps2c)
    @(negedge ps2c)
    if(ps2d === 0)
        $display("Ack found");
    else
        $display("Found high data line where ack was expected");
    
    $display("Received character: %c", word);
end


endmodule