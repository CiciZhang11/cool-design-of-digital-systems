module DE1_SoC (
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output logic [9:0] LEDR,
    input  logic [3:0] KEY,
    input  logic [9:0] SW,
    input  logic       CLOCK_50,
    output logic [7:0] VGA_R, VGA_G, VGA_B,
    output logic       VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS
);

    logic        reset;
    logic [9:0]  x;
    logic [8:0]  y;
    logic [7:0]  r, g, b;

    assign reset = SW[0];  // SW[0] = reset, SW[1] = level select

    // Map DE1 Buttons (Active-Low) to Game Controls (Active-High)
    logic btn_left, btn_right, btn_jump;
    assign btn_left  = ~KEY[2];
    assign btn_jump  = ~KEY[1];
    assign btn_right = ~KEY[0];

    video_driver #(.WIDTH(320), .HEIGHT(240)) vga (
        .CLOCK_50, .reset,
        .x, .y,
        .r, .g, .b,
        .VGA_R, .VGA_G, .VGA_B,
        .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS
    );

    // INSTANTIATE LEVEL 2 HERE (Replacing start_page)
    level2_top lvl2 (
        .clk(CLOCK_50),
        .reset(reset),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .btn_jump(btn_jump),
        .x(x),
        .y(y),
        .r(r), .g(g), .b(b)
    );

    // Turn off Hex displays and LEDs
    assign HEX0 = '1; assign HEX1 = '1; assign HEX2 = '1;
    assign HEX3 = '1; assign HEX4 = '1; assign HEX5 = '1;
    assign LEDR = '0;

endmodule