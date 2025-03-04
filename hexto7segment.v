`timescale 1ns / 1ps

module hexto7segment (
    input [3:0] x,
    output reg [6:0] r
);

always @(*) begin
    case (x)
        4'b0000: r = 7'b0000001; // "0"
        4'b0001: r = 7'b1001111; // "1"
        4'b0010: r = 7'b0010010; // "2"
        4'b0011: r = 7'b0000110; // "3"
        4'b0100: r = 7'b1001100; // "4"
        4'b0101: r = 7'b0100100; // "5"
        4'b0110: r = 7'b0100000; // "6"
        4'b0111: r = 7'b0001111; // "7"
        4'b1000: r = 7'b0000000; // "8"
        4'b1001: r = 7'b0000100; // "9"
        default: r = 7'b1111111; // All segments off
    endcase
end

endmodule
