`timescale 1 ns / 100 ps
module ps2_receive
(
    input clk, reset,
    input ps2c, ps2d,
    input r_enable,
    output [7:0] data_out,
    output reg done_tick
);

localparam
    IDLE = 0,
    START = 1,
    READ_DATA = 2,
    STOP = 3,
    WAIT_RELEASE = 4;

reg [2:0] state_reg, state_next;
reg [3:0] n_reg, n_next;
reg [8:0] word_reg, word_next;


reg [7:0] clock_filter;
wire [7:0] clock_filter_next;
reg ps2c_f;
wire ps2c_f_next;
wire falling_edge, rising_edge;

assign clock_filter_next = {ps2c, clock_filter[7:1]};
assign ps2c_f_next = (clock_filter == 8'hff) ? 1 :
                     (clock_filter == 8'h00) ? 0 :
                     ps2c_f;
assign falling_edge = ps2c_f & ~ps2c_f_next;
assign rising_edge = ~ps2c_f & ps2c_f_next;

always @(posedge clk, posedge reset) begin
    if(reset) begin
        clock_filter <= 0;
        ps2c_f <= 0;
    end else begin
        clock_filter <= clock_filter_next;
        ps2c_f <= ps2c_f_next;
    end
end

always @(posedge clk, posedge reset) begin
    if(reset) begin
        state_reg <= IDLE;
        n_reg <= 0;
        word_reg <= 0;
    end else begin
        state_reg <= state_next;
        n_reg <= n_next;
        word_reg <= word_next;
    end
end

always @* begin
    state_next = state_reg;
    n_next = n_reg;
    word_next = word_reg;

    done_tick = 0;
    
    case(state_reg)
    IDLE: begin
        if(falling_edge && r_enable) begin
            state_next = READ_DATA;
            n_next = 8;
        end
    end

    READ_DATA: begin
        if(falling_edge) begin
            if(n_reg == 0)
                state_next = STOP;
            else begin
                word_next = {ps2d, word_reg[7:1]};
                n_next = n_reg - 1;
            end
        end
    end
    
    STOP: begin
        if(falling_edge) begin
            state_next = WAIT_RELEASE;
        end
    end

    WAIT_RELEASE: 
        if(rising_edge) begin
            done_tick = 1;
            state_next = IDLE;
        end

    endcase
end

assign data_out = word_reg[7:0];

endmodule