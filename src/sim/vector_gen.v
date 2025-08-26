`timescale 1 ns/ 100 ps
module vector_gen #(
    parameter T = 10,//Number of time units in system clock cycle
    parameter B = 80000//Number of time units in PS2 clock cycle
)
(
    input ps2c, ps2d,
    input tx_done_tick,
    output reg rx_clk, rx_data,
    output reg driving_c, driving_d,
    output reg w_enable,
    output reg [7:0] data,
    output reg clk, reset
);


always begin
    clk = 0;
    #(T/2);
    clk = 1;
    #(T/2);
end


initial begin
    initialize();
    send_string_rx("Test reception 1.");

    #100
    
    send_string_tx("Test transmission 1.");

    #100
    
    send_string_rx("Test reception 2.");

    #100
    
    send_string_tx("Test transmission 2.");

    #100
    
    $stop();
end

task initialize(); begin
    w_enable = 0;
    rx_clk = 0;
    rx_data = 0;
    driving_d = 0;
    driving_c = 0;
    data = 0;
    async_reset();
end
endtask

task async_reset(); begin
    reset = 0;
    @(negedge clk);
    reset = 1;
    #(T/4);
    reset = 0;
end
endtask

task send_string_tx(input [159:0] string); 
integer i;
begin
    for(i = 152; i>=0 ; i = i - 8) begin
      #100
        send_packet_tx(string >> i);
    end
end
endtask

task send_packet_tx(input [7:0] dword); begin
    //Release lines
    driving_d = 0;
    driving_c = 0;

    //load data
    data = dword;

    //Pulse write enable
    @(negedge clk);
    w_enable = 1;
    @(negedge clk);
    w_enable = 0;

    //Wait for start bit
    wait(ps2d===0)
    //Wait half a cycle
    #(B/2)

    //Drive clock for data transmission
    driving_c = 1;
    repeat(10) begin
        rx_clk = 1;
        #(B/2);
        rx_clk = 0;
        #(B/2);
    end

    //Acknowledge
    driving_d = 1;
    rx_data = 0;

    rx_clk = 1;
    #(B/2);
    rx_clk = 0;
    #(B/2);

    driving_d = 0;
    driving_c = 0;

    @(tx_done_tick);
    
end
endtask

task send_string_rx(input [135:0] string); 
integer i;
reg [7:0] current_byte;
begin
    for(i = 128; i>=0 ; i = i - 8) begin
        send_packet_rx(string >> i);
    end
end
endtask

task send_packet_rx(input [7:0] dword); 
integer i;
begin
    driving_c = 1;
    driving_d = 1;

    rx_clk = 1;
    rx_data = 1;
    #B;

    rx_data = 0;
    #(B/2);
    rx_clk = 0;
    #(B/2);

    //Send data bits
    for(i = 0; i<8; i = i + 1) begin
        rx_clk = 1;
        rx_data = dword[i];
        #(B/2);
        rx_clk = 0;
        #(B/2);
    end

    //Send parity bits\
    rx_clk = 1;
    rx_data = ~^dword;
    #(B/2);
    rx_clk = 0;
    #(B/2);

    //Send stop bit
    rx_clk = 1;
    rx_data = 1;
    #(B/2);
    rx_clk = 0;
    #(B/2);

    driving_c = 0;
    driving_d = 1;
end
endtask

endmodule