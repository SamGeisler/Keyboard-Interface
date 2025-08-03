module UART_transmit(
input i_clk,
input i_TXD,
input i_send,
input [7:0] i_to_send,
output o_RXD,
output reg [2:0] o_led_status = 0
);
    
reg r_sub_clock = 0;
localparam SUBCOUNT_CYCLES = 868;//115200 baud rate
reg [9:0] r_sub_counter = 0;

reg r_transmitting = 0;
reg [7:0] r_ascii;

reg [1:0] r_shift = 0;

reg r_released = 0;

localparam IDLE = 0;
localparam START = 1;
localparam DATA = 2;
localparam STOP = 3;

reg [1:0] r_state = IDLE;

always @(posedge i_clk) begin
    if(i_send) begin

        if(r_released) begin
            r_transmitting <= 0;
            r_released <= 0;
            if(i_to_send == 8'h12) r_shift[0] <= 0;
            else if(i_to_send == 8'h59) r_shift[1] <= 0;
        end else if(i_to_send == 8'he0) begin
            r_transmitting <= 0;
        end else if(i_to_send == 8'hf0 ) begin
            r_released <= 1;
            r_transmitting <= 0;
        end else begin
            r_transmitting <= 1;
            case(i_to_send)

                8'h12: begin r_shift[0] <= 1; r_transmitting <= 0; end
                8'h59: begin r_shift[1] <= 1; r_transmitting <= 0; end

                8'h1c: r_ascii <= (r_shift ? 8'h41 : 8'h61);//aA
                8'h32: r_ascii <= (r_shift ? 8'h42 : 8'h62);
                8'h21: r_ascii <= (r_shift ? 8'h43 : 8'h63);
                8'h23: r_ascii <= (r_shift ? 8'h44 : 8'h64);
                8'h24: r_ascii <= (r_shift ? 8'h45 : 8'h65);
                8'h2b: r_ascii <= (r_shift ? 8'h46 : 8'h66);
                8'h34: r_ascii <= (r_shift ? 8'h47 : 8'h67);
                8'h33: r_ascii <= (r_shift ? 8'h48 : 8'h68);
                8'h43: r_ascii <= (r_shift ? 8'h49 : 8'h69);
                8'h3b: r_ascii <= (r_shift ? 8'h4a : 8'h6a);
                8'h42: r_ascii <= (r_shift ? 8'h4b : 8'h6b);
                8'h4b: r_ascii <= (r_shift ? 8'h4c : 8'h6c);
                8'h3a: r_ascii <= (r_shift ? 8'h4d : 8'h6d);
                8'h31: r_ascii <= (r_shift ? 8'h4e : 8'h6e);
                8'h44: r_ascii <= (r_shift ? 8'h4f : 8'h6f);
                8'h4d: r_ascii <= (r_shift ? 8'h50 : 8'h70);
                8'h15: r_ascii <= (r_shift ? 8'h51 : 8'h71);
                8'h2d: r_ascii <= (r_shift ? 8'h52 : 8'h72);
                8'h1b: r_ascii <= (r_shift ? 8'h53 : 8'h73);
                8'h2c: r_ascii <= (r_shift ? 8'h54 : 8'h74);
                8'h3c: r_ascii <= (r_shift ? 8'h55 : 8'h75);
                8'h2a: r_ascii <= (r_shift ? 8'h56 : 8'h76);
                8'h1d: r_ascii <= (r_shift ? 8'h57 : 8'h77);
                8'h22: r_ascii <= (r_shift ? 8'h58 : 8'h78);
                8'h35: r_ascii <= (r_shift ? 8'h59 : 8'h79);
                8'h1a: r_ascii <= (r_shift ? 8'h5a : 8'h7a);
                8'h16: r_ascii <= (r_shift ? 8'h21 : 8'h31);//1!
                8'h1e: r_ascii <= (r_shift ? 8'h40 : 8'h32);
                8'h26: r_ascii <= (r_shift ? 8'h23 : 8'h33);
                8'h25: r_ascii <= (r_shift ? 8'h24 : 8'h34);
                8'h2e: r_ascii <= (r_shift ? 8'h25 : 8'h35);
                8'h36: r_ascii <= (r_shift ? 8'h5e : 8'h36);
                8'h3d: r_ascii <= (r_shift ? 8'h26 : 8'h37);
                8'h3e: r_ascii <= (r_shift ? 8'h2a : 8'h38);
                8'h46: r_ascii <= (r_shift ? 8'h28 : 8'h39);
                8'h45: r_ascii <= (r_shift ? 8'h29 : 8'h30);

                8'h0e: r_ascii <= (r_shift ? 8'h7e : 8'h60);//`~
                8'h4e: r_ascii <= (r_shift ? 8'h5f : 8'h2d);//-_
                8'h55: r_ascii <= (r_shift ? 8'h2b : 8'h3d);//=+
                8'h54: r_ascii <= (r_shift ? 8'h7b : 8'h5b);//[{
                8'h5b: r_ascii <= (r_shift ? 8'h7d : 8'h5d);//]}
                8'h5d: r_ascii <= (r_shift ? 8'h7c : 8'h00);//\|
                8'h4c: r_ascii <= (r_shift ? 8'h3a : 8'h3b);//;:
                8'h52: r_ascii <= (r_shift ? 8'h22 : 8'h27);//'"
                8'h41: r_ascii <= (r_shift ? 8'h3c : 8'h2c);//,<
                8'h49: r_ascii <= (r_shift ? 8'h3e : 8'h2e);//.>
                8'h4a: r_ascii <= (r_shift ? 8'h3f : 8'h2f);///?

                8'h66: r_ascii <= 8'h08;//Backspace
                8'h0d: r_ascii <= 8'h09;//Tab
                8'h5a: r_ascii <= 8'h0a;//Line feed
                8'h29: r_ascii <= 8'h20;//Space

                8'h58: begin o_led_status[2] <= ~o_led_status[2]; r_transmitting <= 0; end //Caps lock
                8'h77: begin o_led_status[1] <= ~o_led_status[1]; r_transmitting <= 0; end //Num lock
                8'h7e: begin o_led_status[0] <= ~o_led_status[0]; r_transmitting <= 0; end //Scroll lock
            
                default: r_transmitting <= 0;
            endcase
        end
    end else if(r_state == STOP) begin
        r_transmitting <= 0;
    end

    if(r_sub_counter == SUBCOUNT_CYCLES/2) begin
        r_sub_clock <= 1;        
        r_sub_counter <= r_sub_counter + 1;
    end else if(r_sub_counter == SUBCOUNT_CYCLES - 1) begin
        r_sub_clock <= 0;
        r_sub_counter <= 0;
    end else begin
        r_sub_counter <= r_sub_counter + 1;
    end
end


reg [2:0] r_counter = 0;

reg r_RXD = 1;

always @(posedge i_clk) begin
    
end

always @(posedge r_sub_clock) begin
    case (r_state) 
    IDLE: begin
        r_RXD <= 1;
        if(r_transmitting) 
            r_state <= START;
    end
    
    START: begin
        r_RXD <= 0;
        r_state <= DATA; 
        r_counter <= 0;
    end
    
    DATA: begin
        if(r_counter == 7) begin
            r_state <= STOP;
        end
        r_RXD <= r_ascii[r_counter];
        r_counter <= r_counter + 1;
    end
    
    STOP: begin
        r_counter <= 0;
        r_RXD <= 1;
        r_state <= IDLE;
        
    end
    endcase

end

assign o_RXD = r_RXD;

endmodule
