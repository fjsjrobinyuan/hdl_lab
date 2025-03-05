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

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= 2'b00;
        else
            state <= state + 1'b1;
    end

    always @(*) begin
        case (state)
            2'b00: begin
                sseg = in0;
                an   = 4'b1110; // First digit active
            end
            2'b01: begin
                sseg = in1;
                an   = 4'b1101; // Second digit active
            end
            2'b10: begin
                sseg = in2;
                an   = 4'b1011; // Third digit active
            end
            2'b11: begin
                sseg = in3;
                an   = 4'b0111; // Fourth digit active
            end
            default: begin
                sseg = 7'b1111111;
                an   = 4'b1111;
            end
        endcase
    end

endmodule
