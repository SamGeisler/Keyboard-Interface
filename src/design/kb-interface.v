module kb_interface (
    inout ps2d, ps2c,
    input clk, reset,
    input [2:0] led_status,

    output [7:0] UART_tx_data,
    output reg UART_tx_tick
);

reg [7:0] ps2_tx_data;
reg ps2_tx_tick;
wire [7:0] rx_data;

wire rx_done_tick, tx_done_tick;


assign UART_tx_data = rx_data;

ps2_transceiver ps2_transceiver_unit
    ( .clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .data_in(ps2_tx_data), .write(write_tick),
      .data_out(rx_data), .rx_done_tick(rx_done_tick), .tx_done_tick(tx_done_tick) );


localparam IDLE = 0;
localparam SEND_LED_COMMAND = 1;
localparam RECEIVE_OK = 2;
localparam SEND_LED_FLAGS = 3;

reg [1:0] state_reg, state_next;


always @(posedge clk, posedge reset) 
    if(reset) begin
        state_reg <= IDLE;
    end else begin
        state_reg <= state_next;
    end

always @* begin
    state_next = state_reg;
    UART_tx_tick = 0;
    ps2_tx_tick = 0;


    case(state_reg)
    IDLE: begin
        if(rx_done_tick) begin
            UART_tx_tick = 1;
            if(rx_data == 8'h58 || rx_data == 8'h77 || rx_data == 8'h7e) 
                state_next = SEND_LED_COMMAND;
        end
    end

    SEND_LED_COMMAND: begin
        ps2_tx_data = 8'hed;
        ps2_tx_tick = 1;
        state_next = RECEIVE_OK;
    end

    RECEIVE_OK: begin
        if(rx_done_tick)
            state_next = SEND_LED_FLAGS;
    
    end

    SEND_LED_FLAGS: begin
        ps2_tx_data = led_status;
        ps2_tx_tick = 1;
        state_next = IDLE;
    
    end
    endcase
end



endmodule