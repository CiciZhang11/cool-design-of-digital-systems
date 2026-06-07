// DE1_SoC.sv
// Board top
// Connects switches, keys, VGA framebuffer, and level1_top

module DE1_SoC (
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    KEY, LEDR, SW, CLOCK_50,
    VGA_R, VGA_G, VGA_B,
    VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS
);

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;

    input  logic [3:0] KEY;
    input  logic [9:0] SW;
    input  logic       CLOCK_50;

    output logic [7:0] VGA_R;
    output logic [7:0] VGA_G;
    output logic [7:0] VGA_B;
    output logic       VGA_BLANK_N;
    output logic       VGA_CLK;
    output logic       VGA_HS;
    output logic       VGA_SYNC_N;
    output logic       VGA_VS;

    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;

    // SW[0] is reset
    logic reset;
    assign reset = SW[0];

    // KEYs are active low
    logic btn_left;
    logic btn_right;
    logic btn_up;
    logic btn_a;

    assign btn_left  = ~KEY[3];
    assign btn_right = ~KEY[2];
    assign btn_up    = ~KEY[1];
    assign btn_a     = ~KEY[0];

    // Framebuffer write signals from level1_top
    logic [10:0] fb_x;
    logic [10:0] fb_y;
    logic        fb_pixel_color;
    logic        fb_pixel_write;

    // Debug signals
    logic [9:0] player_x;
    logic [8:0] player_y;
    logic [9:0] bullet_x;
    logic [8:0] bullet_y;
    logic       bullet_active;
    logic [1:0] wall_layers_left;
    logic       hit_player;
    logic       hit_wall;
    logic       player_dead;
    logic       level_clear;

    // Level 1 controller
    level1_top #(
        .SCREEN_W       (640),
        .SCREEN_H       (480),
        .FLOOR_Y        (360),

        .PLAYER_W       (44),
        .PLAYER_H       (47),
        .PLAYER_START_X (280),

        .BULLET_W       (20),
        .BULLET_H       (20),
        .BULLET_START_X (490),
        .BULLET_START_Y (315),

        .WALL_X         (60),
        .WALL_Y         (280),
        .WALL_LAYER_W   (24),
        .WALL_H         (80)
    ) level1_inst (
        .clk              (CLOCK_50),
        .reset            (reset),
        .enable           (~SW[1]),

        .left             (btn_left),
        .right            (btn_right),
        .up               (btn_up),
        .a                (btn_a),

        .fb_x             (fb_x),
        .fb_y             (fb_y),
        .fb_pixel_color   (fb_pixel_color),
        .fb_pixel_write   (fb_pixel_write),

        .player_x         (player_x),
        .player_y         (player_y),
        .bullet_x         (bullet_x),
        .bullet_y         (bullet_y),
        .bullet_active    (bullet_active),
        .wall_layers_left (wall_layers_left),
        .hit_player       (hit_player),
        .hit_wall         (hit_wall),
        .player_dead      (player_dead),
        .level_clear      (level_clear)
    );

    // VGA framebuffer
    VGA_framebuffer fb (
        .clk50        (CLOCK_50),
        .reset        (reset),
        .x            (fb_x),
        .y            (fb_y),
        .pixel_color  (fb_pixel_color),
        .pixel_write  (fb_pixel_write),
        .VGA_R        (VGA_R),
        .VGA_G        (VGA_G),
        .VGA_B        (VGA_B),
        .VGA_CLK      (VGA_CLK),
        .VGA_HS       (VGA_HS),
        .VGA_VS       (VGA_VS),
        .VGA_BLANK_n  (VGA_BLANK_N),
        .VGA_SYNC_n   (VGA_SYNC_N)
    );

    // Debug LEDs
    assign LEDR[0] = reset;
    assign LEDR[1] = ~SW[1];
    assign LEDR[2] = btn_left;
    assign LEDR[3] = btn_right;
    assign LEDR[4] = btn_up;
    assign LEDR[5] = hit_wall;
    assign LEDR[6] = hit_player;
    assign LEDR[7] = level_clear;
    assign LEDR[8] = player_dead;
    assign LEDR[9] = bullet_active;

endmodule  // DE1_SoC
