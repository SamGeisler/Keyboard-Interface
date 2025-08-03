`timescale 1 ns/ 10 ps
module vector_gen #(
    parameter T = 10,//Number of time units in system clock cycle
    parameter B = 80000//Number of time units in PS2 clock cycle
)
(
    input tx_finished,
    input ps2c, ps2d,
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
    send_packet(8'h48);
    send_packet(8'h45);
    send_packet(8'h4C);
    send_packet(8'h4C);
    send_packet(8'h4F);
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
    @(negedge clk);
    reset = 1;
    #(T/4);
    reset = 0;
end
endtask

task send_packet(input [7:0] dword); begin
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
end
endtask


endmodule