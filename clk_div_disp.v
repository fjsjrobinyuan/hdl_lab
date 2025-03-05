`timescale 1ns / 1ps

module clk_div_disp(
    input clk,
    input reset,
    output clk_out
);

    reg [3:0] COUNT;

    assign clk_out = COUNT[3];

    always @(posedge clk) begin
        if (reset)
            COUNT <= 0;
        else
            COUNT <= COUNT + 1;
    end

endmodule
