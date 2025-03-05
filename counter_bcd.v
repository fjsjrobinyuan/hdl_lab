`timescale 1ns / 1ps

module counter_bcd(
    input [3:0] step_option,
    input [2:0] hold_option,
    input clk,
    input reset,
    output reg [15:0] bcd_value,
    output reg flash_slow,
    output reg flash_fast
);

    // 1 Hz clock divider (assumes a 50 MHz input clock)
    reg [25:0] clock_divisor;
    reg clk_out_enable;
    parameter MAX_COUNT = 9999;
    reg [13:0] count;
    
    // Divider for fast flash (for expired state: 2 Hz toggle)
    reg [24:0] flash_fast_divisor;
    
    // One-shot generation for coin addition
    reg [3:0] step_option_prev;
    reg [3:0] step_pulse;
    
    // Counter update logic
    always @(posedge clk) begin
        if (reset) begin
            clock_divisor <= 0;
            clk_out_enable <= 0;
            count <= 0;
            step_option_prev <= 0;
            step_pulse <= 0;
        end else begin
            if (clock_divisor == 26'd50000000 - 1) begin
                clock_divisor <= 0;
                clk_out_enable <= 1;
            end else begin
                clock_divisor <= clock_divisor + 1;
                clk_out_enable <= 0;
            end
            
            if (clk_out_enable) begin
                // One-shot: detect rising edge on coin-addition inputs.
                step_pulse <= step_option & ~step_option_prev;
                step_option_prev <= step_option;
                
                // Update count: hold operations have highest priority.
                if (hold_option == 3'b001)
                    count <= 10;
                else if (hold_option == 3'b010)
                    count <= 205;
                // Coin addition.
                else if (step_pulse != 4'b0000) begin
                    case (step_pulse)
                        4'b0001: count <= (count + 10  > MAX_COUNT) ? MAX_COUNT : count + 10;
                        4'b0010: count <= (count + 180 > MAX_COUNT) ? MAX_COUNT : count + 180;
                        4'b0100: count <= (count + 200 > MAX_COUNT) ? MAX_COUNT : count + 200;
                        4'b1000: count <= (count + 550 > MAX_COUNT) ? MAX_COUNT : count + 550;
                        default: count <= count;
                    endcase
                end 
                else if (count > 0)
                    count <= count - 1;
            end
        end
    end

    // Flash slow: when count < 200 and nonzero, toggle at 1 Hz (50% duty cycle).
    always @(posedge clk) begin
        if (reset)
            flash_slow <= 0;
        else if (clk_out_enable) begin
            if (count < 200 && count != 0)
                flash_slow <= ~flash_slow;
            else
                flash_slow <= 0;
        end
    end

    // Flash fast: when count == 0, toggle at 2 Hz.
    always @(posedge clk) begin
        if (reset) begin
            flash_fast_divisor <= 0;
            flash_fast <= 0;
        end else begin
            if (flash_fast_divisor == 25'd25000000 - 1) begin
                flash_fast_divisor <= 0;
                if (count == 0)
                    flash_fast <= ~flash_fast;
                else
                    flash_fast <= 0;
            end else begin
                flash_fast_divisor <= flash_fast_divisor + 1;
            end
        end
    end

    // Conversion FSM for binary-to-BCD conversion (double-dabble method)
    // Uses a 30-bit shift register: upper 16 bits for BCD, lower 14 bits for binary.
    reg [29:0] conv_data;
    reg [2:0] conv_state;
    reg conv_rdy;
    reg [3:0] conv_sh_counter;
    reg [1:0] conv_add_counter;
    reg conv_start;
    
    localparam IDLE   = 3'b000;
    localparam SETUP  = 3'b001;
    localparam ADD    = 3'b010;
    localparam SHIFT  = 3'b011;
    localparam DONE   = 3'b100;

    always @(posedge clk) begin
        if (reset)
            conv_start <= 0;
        else if (clk_out_enable)
            conv_start <= 1;
        else if (conv_state == IDLE && conv_rdy)
            conv_start <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            conv_state <= IDLE;
            conv_rdy <= 0;
            conv_sh_counter <= 0;
            conv_add_counter <= 0;
            conv_data <= 0;
        end else begin
            if (conv_start && conv_state == IDLE) begin
                conv_data <= {16'b0, count};
                conv_state <= SETUP;
                conv_rdy <= 0;
                conv_sh_counter <= 0;
                conv_add_counter <= 0;
            end else begin
                case(conv_state)
                    IDLE: conv_rdy <= 0;
                    SETUP: conv_state <= ADD;
                    ADD: begin
                        case(conv_add_counter)
                            2'b00: begin
                                if(conv_data[17:14] > 4)
                                    conv_data[29:14] <= conv_data[29:14] + 3;
                                conv_add_counter <= conv_add_counter + 1;
                            end
                            2'b01: begin
                                if(conv_data[21:18] > 4)
                                    conv_data[29:18] <= conv_data[29:18] + 3;
                                conv_add_counter <= conv_add_counter + 1;
                            end
                            2'b10: begin
                                if(conv_data[25:22] > 4)
                                    conv_data[29:22] <= conv_data[29:22] + 3;
                                conv_add_counter <= conv_add_counter + 1;
                            end
                            2'b11: begin
                                if(conv_data[29:26] > 4)
                                    conv_data[29:26] <= conv_data[29:26] + 3;
                                conv_add_counter <= 0;
                                conv_state <= SHIFT;
                            end
                        endcase
                    end
                    SHIFT: begin
                        conv_sh_counter <= conv_sh_counter + 1;
                        conv_data <= conv_data << 1;
                        if(conv_sh_counter == 13) begin
                            conv_sh_counter <= 0;
                            conv_state <= DONE;
                        end else begin
                            conv_state <= ADD;
                        end
                    end
                    DONE: begin
                        conv_rdy <= 1;
                        conv_state <= IDLE;
                    end
                    default: conv_state <= IDLE;
                endcase
            end
        end
    end

    always @(posedge clk) begin
        if (reset)
            bcd_value <= 0;
        else if (conv_rdy)
            bcd_value <= conv_data[29:14];
    end

endmodule
