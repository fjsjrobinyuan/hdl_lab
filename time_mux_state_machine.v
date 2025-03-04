`timescale 1ns / 1ps

module time_mux_state_machine(
    input clk,
    input reset,
    input [6:0] in0,
    input [6:0] in1,
    input [6:0] in2,
    input [6:0] in3,
    output reg [3:0] an,
    output reg [6:0] sseg
    );

    reg [1:0] state = 2'b00;

    always @ (posedge clk or posedge reset) begin
        if (reset)
            state <= 2'b00;
        else
            state <= state + 1'b1;
    end

    always @(*) begin
        case (state)
            2'b00: begin
                sseg = in0;
                an = 4'b1110; // Activate first display (Active Low)
            end
            2'b01: begin
                sseg = in1;
                an = 4'b1101; // Activate second display
            end
            2'b10: begin
                sseg = in2;
                an = 4'b1011; // Activate third display
            end
            2'b11: begin
                sseg = in3;
                an = 4'b0111; // Activate fourth display
            end
            default: begin
                sseg = 7'b1111111; // All segments off
                an = 4'b1111; // All displays off
            end
        endcase
    end

endmodule
