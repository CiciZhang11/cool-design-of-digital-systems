module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
                CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    input  logic [3:0] KEY;
    input  logic [9:0] SW;
    input  logic       CLOCK_50;
    output logic [7:0] VGA_R, VGA_G, VGA_B;
    output logic       VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;

    logic        reset;
    logic [9:0]  x;
    logic [8:0]  y;
    logic [7:0]  r, g, b;

    assign reset = SW[0];  // SW[0] = reset, SW[1] = level select

    video_driver #(.WIDTH(320), .HEIGHT(240)) vga (
        .CLOCK_50, .reset,
        .x, .y,
        .r, .g, .b,
        .VGA_R, .VGA_G, .VGA_B,
        .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS
    );

    start_page sp (
        .clk   (CLOCK_50),
        .reset,
        .x, .y,
        .r, .g, .b
    );

    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;

    assign LEDR = '0;

endmodule  // DE1_SoC


`timescale 1 ps / 1 ps
module DE1_SoC_testbench();
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR, SW;
    logic [3:0] KEY;
    logic        CLOCK_50;
    logic [7:0]  VGA_R, VGA_G, VGA_B;
    logic        VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;

    DE1_SoC dut (.*);

    parameter T = 20;
    initial begin
        CLOCK_50 = 0;
        forever #(T/2) CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        SW = 10'b0;
        #(T*10);
        $stop();
    end

endmodule  // DE1_SoC_testbench