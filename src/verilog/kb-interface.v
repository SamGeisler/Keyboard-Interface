module kb_interface(
input i_clk,
inout io_PS2_clk,
inout io_PS2_data,
input [2:0] i_led_status,
output reg [8:0] o_keycode = 0,
output reg o_ready = 0,
output reg [3:0] o_db_led1 = 0,//Current FSM state
output reg [3:0] o_db_led2 = 0,//r_current_bit
output reg [3:0] o_db_led3 = 0,//PS2 clock falling edge count: triple buffered
output reg [3:0] o_db_led4 = 0//PS2 clock falling edge count: negedge
);

//Divide system clock to PS/2 interface speed. This clock is assigned to r_TX_clk when writing to the device.
localparam NUM_CYCLES_IN_SLOW_CYCLE = 80000;
reg [15:0] r_slow_clock_counter = 0;
reg r_slow_clock = 0;
reg r_match_clock_flag = 0;

//Bi-Directional buffer controls
reg r_write_enable = 0;

reg r_TX_clk = 1;
wire w_RX_clk = io_PS2_clk;
assign io_PS2_clk = r_write_enable ? (r_match_clock_flag ? r_TX_clk : r_slow_clock) : 1'bZ;

reg r_TX_data = 1;
wire w_RX_data = io_PS2_data;
assign io_PS2_data = r_write_enable ? r_TX_data : 1'bZ;

//For pulsing o_ready
reg r_pulse_ready1 = 0;
reg r_pulse_ready2 = 0;

//For detecting falling edge of PS/2 closk
reg [2:0] r_PS2_clk_sync = 3'b111;

//FSM 
localparam IDLE = 0;
localparam READING = 1;
localparam SEND_LED_COMMAND = 2;
localparam DELAY1 = 3;//Between reading lock key and sending command
localparam DELAY2 = 4;//Between receiving okay and sending flags
localparam RECEIVE_OK = 5;
localparam SEND_LED_FLAGS = 6;

reg r_state = IDLE;

//FSM counters:
reg [3:0] r_current_bit = 0; //Used for all reading and writing operations
reg [13:0] r_delay_counter = 0; //For DELAY1 and DELAY2 states

localparam LED_COMMAND = 8'hed;
localparam DELAY_CYCLES = 12000;//120us

always @(negedge w_RX_clk) begin
    o_db_led4 <= o_db_led4 + 1;
end

always @(posedge i_clk) begin

    //Divide into slow clock for PS/2 transmission (clock is reset before sending packet)
    if(r_slow_clock_counter == NUM_CYCLES_IN_SLOW_CYCLE/2 - 1) begin
        r_slow_clock <= ~r_slow_clock;
        r_slow_clock_counter <= 0;
    end else
        r_slow_clock_counter <= r_slow_clock_counter + 1;

    //Record PS/2 clock for edge detection
    r_PS2_clk_sync[0] <= w_RX_clk;
    r_PS2_clk_sync[1] <= r_PS2_clk_sync[0];
    r_PS2_clk_sync[2] <= r_PS2_clk_sync[1];

    //Debugging
    o_db_led1 <= r_state;
    o_db_led2 <= r_current_bit;

    //FSM
    case (r_state) 
    IDLE: begin
        r_write_enable <= 0;
        r_pulse_ready1 <= 0;
        if(r_PS2_clk_sync[2] && !w_RX_clk) begin
            o_db_led3 <= o_db_led3 + 1;
            r_PS2_clk_sync <= 0;
            r_state <= READING;
            r_current_bit <= 1;
        end
    end

    READING: begin
        r_write_enable <= 0;
        if(r_PS2_clk_sync[2] && !w_RX_clk) begin
            o_db_led3 <= o_db_led3 + 1;
            r_PS2_clk_sync <= 0;
            case (r_current_bit)                 
                default: o_keycode[r_current_bit] <= w_RX_data;
                9: ;
                10: begin
                    r_pulse_ready1 <= 1;
                    if(o_keycode[8:1] == 8'h58 || o_keycode[8:1] == 8'h77 || o_keycode[8:1] == 8'h7e) begin
                        r_state <= DELAY1;
                        r_delay_counter <= 0;
                    end else r_state <= IDLE;
                end
            endcase
            r_current_bit <= r_current_bit + 1;
        end
    end

    DELAY1: begin
        r_write_enable <= 1;
        r_match_clock_flag <= 0;
        r_TX_clk <= 0;
        r_TX_data <= 0;
        if(r_delay_counter == DELAY_CYCLES) begin
            r_state <= SEND_LED_COMMAND;
            r_current_bit <= 0;
            r_delay_counter <= 0;
        end else r_delay_counter <= r_delay_counter + 1;
    end

    SEND_LED_COMMAND: begin
        r_write_enable <= 1;
        
        //Set up divided clock for output (start with rising edge)
        if(!r_match_clock_flag)begin
            r_match_clock_flag <= 1;
            r_slow_clock <= 1;
            r_slow_clock_counter <= 0;
        end

        //Change data on rising edges for reading on falling edges
        if(!r_PS2_clk_sync[2] && w_RX_clk) begin
            r_PS2_clk_sync <= 1;
            r_current_bit <= r_current_bit + 1;
            case(r_current_bit)
                0: r_TX_data <= 0;
                9: r_TX_data <= ^LED_COMMAND; //Odd parity
                10: r_TX_data <= 1;
                11: begin
                    r_state <= RECEIVE_OK;
                    r_current_bit <= 0;
                    r_delay_counter <= 0;
                end
                default: r_TX_data <= LED_COMMAND[r_current_bit-1];
            endcase
        end
    end

    RECEIVE_OK: begin
        r_write_enable <= 0;
        if(r_PS2_clk_sync[2] && !w_RX_clk) begin
            r_PS2_clk_sync <= 0;
            if(r_current_bit == 10)
                r_state <= DELAY2;
            else r_current_bit <= r_current_bit + 1;
        end
    end

    DELAY2: begin
        r_write_enable <= 1;
        r_match_clock_flag <= 0;
        r_TX_clk <= 0;
        r_TX_data <= 0;
        if(r_delay_counter == DELAY_CYCLES) begin
            r_state <= SEND_LED_FLAGS;
            r_current_bit <= 0;
            r_delay_counter <= 0;
        end else r_delay_counter <= r_delay_counter + 1;
    end

    SEND_LED_FLAGS: begin
        r_write_enable <= 1;
        
        //Set up divided clock for output (start with rising edge)
        if(!r_match_clock_flag)begin
            r_match_clock_flag <= 1;
            r_slow_clock <= 1;
            r_slow_clock_counter <= 0;
        end

        //Change data on rising edges for reading on falling edges
        if(!r_PS2_clk_sync[2] && w_RX_clk) begin
            r_PS2_clk_sync <= 1;
            r_current_bit <= r_current_bit + 1;
            case(r_current_bit)
                0: r_TX_data <= 0;
                1: r_TX_data <= i_led_status[0];
                2: r_TX_data <= i_led_status[1];
                3: r_TX_data <= i_led_status[2];
                9: r_TX_data <= ^i_led_status; //Odd parity
                10: r_TX_data <= 1;
                11: begin
                    r_write_enable <= 0;
                    r_state <= IDLE;
                    r_match_clock_flag <= 0;
                end
                default: r_TX_data <= 0;
            endcase
        end
    end
    endcase
end

//Pulse o_ready
always @(posedge i_clk) begin
    r_pulse_ready2 <= r_pulse_ready1;
    if(r_pulse_ready1 && !r_pulse_ready2)
        o_ready <= 1;
    else if (o_ready)
        o_ready <= 0;
end

endmodule
