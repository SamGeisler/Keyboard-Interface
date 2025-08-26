module kb_interface (
    inout ps2d, ps2c,
    input clk, reset,
    input [2:0] led_status,

    output [7:0] UART_tx_data,
    output reg UART_tx_tick
);

reg [7:0] ps2_tx_data, ps2_tx_data_next;
reg ps2_tx_tick;
wire [7:0] rx_data;

wire rx_done_tick, tx_done_tick;


assign UART_tx_data = rx_data;

ps2_transceiver ps2_transceiver_unit
    ( .clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .data_in(ps2_tx_data), .write(ps2_tx_tick),
      .data_out(rx_data), .rx_done_tick(rx_done_tick), .tx_done_tick(tx_done_tick) );


localparam IDLE = 0;
localparam SEND_LED_COMMAND = 1;
localparam RECEIVE_OK = 2;
localparam SEND_LED_FLAGS = 3;
localparam WAIT_TX1 = 4;
localparam WAIT_TX2 = 5;
localparam DELAY_SEND = 6;

reg [2:0] state_reg, state_next;

reg [7:0] delay_counter, delay_counter_next;

always @(posedge clk, posedge reset) 
    if(reset) begin
        state_reg <= IDLE;
        ps2_tx_data <= 0;
        delay_counter <= 0;
    end else begin
        state_reg <= state_next;
        ps2_tx_data <= ps2_tx_data_next;
        delay_counter <= delay_counter_next;
    end

always @* begin
    state_next = state_reg;
    ps2_tx_data_next = ps2_tx_data;
    delay_counter_next = delay_counter;
    UART_tx_tick = 0;
    ps2_tx_tick = 0;


    case(state_reg)
    IDLE: begin
        if(rx_done_tick) begin
            UART_tx_tick = 1;
            if(rx_data == 8'h58 || rx_data == 8'h77 || rx_data == 8'h7e) 
                state_next = DELAY_SEND;
                delay_counter_next = -1;
        end
    end

    DELAY_SEND: begin
        if(delay_counter == 0) 
            state_next = SEND_LED_COMMAND;
        else
            delay_counter_next = delay_counter - 1;
    end

    SEND_LED_COMMAND: begin
        ps2_tx_data_next = 8'hed;
        ps2_tx_tick = 1;
        state_next = WAIT_TX1;
    end

    WAIT_TX1:
        if(tx_done_tick)
            state_next = RECEIVE_OK;

    RECEIVE_OK: begin
        if(rx_done_tick)
            state_next = SEND_LED_FLAGS;
    
    end

    SEND_LED_FLAGS: begin
        ps2_tx_data_next = led_status;
        ps2_tx_tick = 1;
        state_next = WAIT_TX2;
    end

    WAIT_TX2:
        if(tx_done_tick)
            state_next = IDLE;


    endcase
end



endmodule