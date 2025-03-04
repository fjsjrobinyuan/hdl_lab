`timescale 1ns / 1ps

module counter_bcd (
    input [3:0] step_option,
    input [2:0] hold_option,
    input clk,
    input reset,
    output reg [15:0] bcd_value,
    output reg flash_slow, 
    output reg flash_fast 
);

    reg [25:0] clock_divisor;
    reg clk_out_enable = 1'b0;
    reg [13:0] count = 14'd0; 

    parameter MAX_COUNT = 9999;

    // Clock Divider to Generate 1 Hz Enable Signal
    always @(posedge clk) begin
        if (reset) begin
            clock_divisor <= 0;
            clk_out_enable <= 0;
        end
        else if (clock_divisor == 26'd50000000 - 1) begin
            clock_divisor <= 0;
            clk_out_enable <= 1;
        end else begin
            clock_divisor <= clock_divisor + 1;
            clk_out_enable <= 0;
        end
    end

    // Main Counter Logic with Enable Signal
    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            bcd_value <= 16'b0;
        end 
        else if (clk_out_enable) begin
            // Handle Hold Options (Reset)
            if (hold_option == 3'b001) begin
                count <= 10;
            end 
            else if (hold_option == 3'b010) begin
                count <= 205;
            end 
            // Handle Step Options (Addition)
            else if (|step_option) begin
                case (step_option)
                    4'b0001: count <= (count + 10 > MAX_COUNT) ? MAX_COUNT : count + 10;
                    4'b0010: count <= (count + 180 > MAX_COUNT) ? MAX_COUNT : count + 180;
                    4'b0100: count <= (count + 200 > MAX_COUNT) ? MAX_COUNT : count + 200;
                    4'b1000: count <= (count + 550 > MAX_COUNT) ? MAX_COUNT : count + 550;
                endcase
            end 
            // Default behavior: Decrement the counter every second
            else if (count > 0) begin
                count <= count - 1;
            end
            
            // Update BCD Value
            bcd_value <= { (count / 1000) % 10, (count / 100) % 10, (count / 10) % 10, count % 10 };
        end
    end

    // Flashing Signal Logic
    always @(posedge clk) begin
        if (reset) begin
            flash_fast <= 0;
            flash_slow <= 0;
        end
        else if (clk_out_enable) begin
            flash_fast <= (count == 0) ? ~flash_fast : 0;
            flash_slow <= (count < 200) ? ~flash_slow : 0;
        end
    end

endmodule
