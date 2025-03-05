`timescale 1ns / 1ps

module parking_meter_top(
    input clk,
    input reset,
    input buttonU, buttonL, buttonR, buttonD,
    input switch0, switch1,
    output [3:0] an,
    output [6:0] sseg
);

    wire [3:0] step_option;
    wire [2:0] hold_option;
    wire [15:0] bcd_value;
    wire flash_slow, flash_fast;

    // Input module: Debouncer and one-shot generator
    button_debouncer db(
        .clk(clk),
        .buttonU(buttonU),
        .buttonL(buttonL),
        .buttonR(buttonR),
        .buttonD(buttonD),
        .switch0(switch0),
        .switch1(switch1),
        .step_option(step_option),
        .hold_option(hold_option)
    );

    // Controller module: Binary counter with integrated FSM-based BCD conversion and flash signals
    counter_bcd counter(
        .step_option(step_option),
        .hold_option(hold_option),
        .clk(clk),
        .reset(reset),
        .bcd_value(bcd_value),
        .flash_slow(flash_slow),
        .flash_fast(flash_fast)
    );

    // Output module: Multiplexed 7-segment display driver.
    // When flash_fast or flash_slow is active, the display input is set to 16'hFFFF (which decodes to blank).
    time_multiplexing_main display(
        .clk(clk),
        .reset(reset),
        .sw(flash_fast ? 16'hFFFF : (flash_slow ? 16'hFFFF : bcd_value)),
        .an(an),
        .sseg(sseg)
    );

endmodule
