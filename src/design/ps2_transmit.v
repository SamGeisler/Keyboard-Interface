`timescale 1 ns/ 10 ps
module ps2_transmit 
(
    input clk, reset,
    input [7:0] data_in,
    input w_enable,
    inout ps2d, ps2c,

    output reg tx_finished,
    output reg tx_idle
);

localparam
    IDLE = 1,
    REQUEST = 2,
    START = 3,
    SEND_DATA = 4,
    STOP = 5;

localparam NUM_REQUEST_CYCLES = 12000;//120 us

reg we_data, we_clock;
reg tx_data, tx_clock;
reg [7:0] clock_filter;
wire [7:0] clock_filter_next;
reg ps2c_f;
wire ps2c_f_next;
wire falling_edge;

reg [2:0] state_reg, state_next;
reg [8:0] data_reg, data_next;
reg [3:0] n_reg, n_next;

reg [$clog2(NUM_REQUEST_CYCLES)-1:0] request_counter, rc_next;

//Tri-state buffers
assign ps2d = we_data ? tx_data : 1'bz;
assign ps2c = we_clock ? tx_clock : 1'bz;

//Filter clock & generate falling edges
always @(posedge clk, posedge reset)
    if(reset) begin
        clock_filter <= 0;
        ps2c_f <= 0;
    end else begin
        clock_filter <= clock_filter_next;
        ps2c_f <= ps2c_f_next;
    end

assign ps2c_f_next = (clock_filter == 8'hFF) ? 1 :
                     (clock_filter == 8'h00) ? 0 :
                     ps2c_f;
assign clock_filter_next = {ps2c, clock_filter[7:1]};
assign falling_edge = ~ps2c_f_next & ps2c_f;

//Update state and data registers
always @(posedge clk, posedge reset)
    if(reset) begin
        state_reg <= IDLE;
        data_reg <= 0;
        n_reg <= 0;
        request_counter <= 0;
    end else begin
        state_reg <= state_next;
        data_reg <= data_next;
        n_reg <= n_next;
        request_counter <= rc_next;
    end

//Next state and data logic
always @* begin
    state_next = state_reg;
    n_next = n_reg;
    data_next = data_reg;

    we_data = 0;
    we_clock = 0;

    tx_finished = 0;
    tx_idle = 0;

    case(state_reg)
    IDLE: begin
        tx_idle = 0;
        if(w_enable) begin
            state_next = REQUEST;
            rc_next = 0;
        end
    end

    REQUEST: begin
        we_clock = 1;
        tx_clock = 0;
        if(request_counter == NUM_REQUEST_CYCLES - 1) begin
            state_next = START;
        end else 
            rc_next = request_counter + 1;
    end

    START: begin
        we_data = 1;
        tx_data = 0;
        if(falling_edge) begin
            state_next = SEND_DATA;
            n_next = 8;
            data_next = {~^data_in, data_in};
        end
    end

    SEND_DATA: begin
        we_data = 1;
        tx_data = data_reg[0];
        if(falling_edge) 
            if(n_reg == 0) begin
                state_next = STOP;
            end else begin
                n_next = n_reg - 1;
                data_next = {1'b0, data_reg[8:1]};
            end
    end

    STOP: begin
        we_data = 0;
        if(falling_edge) begin
            state_next = IDLE;
            tx_finished = 1;
        end
    end

    endcase
end

endmodule