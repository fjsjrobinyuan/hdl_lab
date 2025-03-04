`timescale 1ns / 1ps

module button_debouncer (
    input clk,                  
    input buttonU, buttonL, buttonR, buttonD, 
    input switch0, switch1,     
    output reg [3:0] step_option, 
    output reg [2:0] hold_option  
);

    reg [19:0] counterU, counterL, counterR, counterD, counterS0, counterS1;
    reg buttonU_state, buttonL_state, buttonR_state, buttonD_state;
    reg switch0_state, switch1_state;

    parameter DEBOUNCE_LIMIT = 20'd1000000;

    always @(posedge clk) begin
        // Debounce and sync logic for all buttons and switches
        if (buttonU == buttonU_state) 
            if (counterU < DEBOUNCE_LIMIT) counterU <= counterU + 1;
        else begin counterU <= 0; buttonU_state <= buttonU; end
        
        if (buttonL == buttonL_state) 
            if (counterL < DEBOUNCE_LIMIT) counterL <= counterL + 1;
        else begin counterL <= 0; buttonL_state <= buttonL; end
        
        if (buttonR == buttonR_state) 
            if (counterR < DEBOUNCE_LIMIT) counterR <= counterR + 1;
        else begin counterR <= 0; buttonR_state <= buttonR; end
        
        if (buttonD == buttonD_state) 
            if (counterD < DEBOUNCE_LIMIT) counterD <= counterD + 1;
        else begin counterD <= 0; buttonD_state <= buttonD; end
        
        if (switch0 == switch0_state) 
            if (counterS0 < DEBOUNCE_LIMIT) counterS0 <= counterS0 + 1;
        else begin counterS0 <= 0; switch0_state <= switch0; end
        
        if (switch1 == switch1_state) 
            if (counterS1 < DEBOUNCE_LIMIT) counterS1 <= counterS1 + 1;
        else begin counterS1 <= 0; switch1_state <= switch1; end
    end

    always @(*) begin
        step_option = 4'b0000;
        if (buttonU_state) step_option = 4'b0001; 
        if (buttonL_state) step_option = 4'b0010; 
        if (buttonR_state) step_option = 4'b0100; 
        if (buttonD_state) step_option = 4'b1000; 
    end

    always @(*) begin
        hold_option = 3'b000;
        if (switch0_state) hold_option = 3'b001; 
        if (switch1_state) hold_option = 3'b010; 
    end

endmodule
