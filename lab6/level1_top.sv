// level1_top.sv
// level 1 game logic
// outputs line endpoints for cannon wall and bullet
// player position is updated here
// player drawing is done by lilcat_shape in DE1_SoC
module level1_top #(
    parameter int SCREEN_W       = 640,
    parameter int SCREEN_H       = 480,

    parameter int FLOOR_Y        = 360,

    parameter int PLAYER_W       = 44,
    parameter int PLAYER_H       = 47,
    parameter int PLAYER_START_X = 280,

    parameter int BULLET_W       = 20,
    parameter int BULLET_H       = 20,
    parameter int BULLET_START_X = 490,
    parameter int BULLET_START_Y = 315,

    parameter int WALL_X         = 60,
    parameter int WALL_Y         = 280,
    parameter int WALL_LAYER_W   = 24,
    parameter int WALL_H         = 80
)(
    input  logic        clk,
    input  logic        reset,
    input  logic        update_en,
    input  logic        enable,

    input  logic        left,
    input  logic        right,
    input  logic        up,
    input  logic        a,

    input  logic [5:0]  line_num,

    output logic [10:0] x0,
    output logic [10:0] y0,
    output logic [10:0] x1,
    output logic [10:0] y1,
    output logic        line_valid,

    output logic [9:0]  player_x,
    output logic [8:0]  player_y,
    output logic        facing_left,
    output logic        on_ground,
    output logic [1:0]  player_frame,

    output logic [9:0]  bullet_x,
    output logic [8:0]  bullet_y,
    output logic        bullet_active,

    output logic [1:0]  wall_layers_left,
    output logic        hit_player,
    output logic        hit_wall,
    output logic        player_dead,
    output logic        level_clear
);

    // Line ranges
    localparam logic [5:0] CANNON_START = 6'd0;
    localparam logic [5:0] CANNON_END   = 6'd7;    // 8 lines

    localparam logic [5:0] WALL_START   = 6'd8;
    localparam logic [5:0] WALL_END     = 6'd19;   // 12 lines

    localparam logic [5:0] BULLET_START = 6'd20;
    localparam logic [5:0] BULLET_END   = 6'd24;   // 5 lines

    localparam logic [8:0] BULLET_START_Y_9 = BULLET_START_Y;

    logic game_active;
    logic bullet_enable;
    logic jump_button;

    assign game_active   = enable && !level_clear;
    assign bullet_enable = game_active;
    assign jump_button   = up || a;

    // local line numbers
    logic [5:0] wall_line_num_6;
    logic [5:0] bullet_line_num_6;

    assign wall_line_num_6   = line_num - WALL_START;
    assign bullet_line_num_6 = line_num - BULLET_START;

    // player position update
    player_update_pos #(
        .SCREEN_W       (SCREEN_W),
        .SCREEN_H       (SCREEN_H),
        .PLAYER_W       (PLAYER_W),
        .PLAYER_H       (PLAYER_H),
        .PLAYER_START_X (PLAYER_START_X),
        .FLOOR_Y        (FLOOR_Y),
        .MOVE_STEP      (6),
        .JUMP_VEL_INIT  (14),
        .GRAVITY        (1),
        .LEFT_LIMIT     (140),
        .RIGHT_LIMIT    (448)
    ) player_pos_inst (
        .clk        (clk),
        .reset      (reset),
        .update_en  (update_en),
        .enable     (game_active),
        .move_left  (left),
        .move_right (right),
        .jump       (jump_button),
        .player_x   (player_x),
        .player_y   (player_y),
        .on_ground  (on_ground)
    );

    // facing direction and frame
    always_ff @(posedge clk) begin
        if (reset) begin
            facing_left  <= 1'b0;
            player_frame <= 2'd0;
        end // end if
        else if (update_en && game_active) begin
            if (left && !right) begin
                facing_left  <= 1'b1;
                player_frame <= player_frame + 2'd1;
            end // end if
            else if (right && !left) begin
                facing_left  <= 1'b0;
                player_frame <= player_frame + 2'd1;
            end // end else if
        end // end else if
    end // end always_ff

    // bullet update
    bullet_update_pos #(
        .SCREEN_W     (SCREEN_W),
        .BULLET_W     (BULLET_W),
        .START_X      (BULLET_START_X),
        .START_Y      (BULLET_START_Y),
        .BULLET_SPEED (4),
        .COOLDOWN_MAX (20)
    ) bullet_pos_inst (
        .clk           (clk),
        .reset         (reset),
        .update_en     (update_en),
        .enable        (bullet_enable),
        .hit_wall      (hit_wall),
        .hit_player    (hit_player),
        .spawn_y       (BULLET_START_Y_9),
        .bullet_x      (bullet_x),
        .bullet_y      (bullet_y),
        .bullet_active (bullet_active)
    );

    // collision
    level1_collision #(
        .PLAYER_W     (PLAYER_W),
        .PLAYER_H     (PLAYER_H),
        .BULLET_W     (BULLET_W),
        .BULLET_H     (BULLET_H),
        .WALL_X       (WALL_X),
        .WALL_Y       (WALL_Y),
        .WALL_LAYER_W (WALL_LAYER_W),
        .WALL_H       (WALL_H)
    ) collision_inst (
        .player_x         (player_x),
        .player_y         (player_y),
        .bullet_x         (bullet_x),
        .bullet_y         (bullet_y),
        .bullet_active    (bullet_active && game_active),
        .wall_layers_left (wall_layers_left),
        .hit_player       (hit_player),
        .hit_wall         (hit_wall)
    );

    // wall controller
    wall_controller #(
        .START_LAYERS (3)
    ) wall_ctrl_inst (
        .clk              (clk),
        .reset            (reset),
        .update_en        (update_en),
        .enable           (game_active),
        .hit_wall         (hit_wall),
        .wall_layers_left (wall_layers_left),
        .level_clear      (level_clear)
    );

    // player dead debug flag
    always_ff @(posedge clk) begin
        if (reset) begin
            player_dead <= 1'b0;
        end // end if
        else if (enable && update_en && hit_player) begin
            player_dead <= 1'b1;
        end // end else if
    end // end always_ff

    // shape wires
    logic [10:0] cannon_x0, cannon_y0, cannon_x1, cannon_y1;
    logic [10:0] wall_x0, wall_y0, wall_x1, wall_y1;
    logic [10:0] bullet_x0, bullet_y0, bullet_x1, bullet_y1;

    logic wall_line_valid;

    // shape modules
    cannon_shape #(
        .FLOOR_Y (FLOOR_Y)
    ) cannon_shape_inst (
        .line_num (line_num[3:0]),
        .x0       (cannon_x0),
        .y0       (cannon_y0),
        .x1       (cannon_x1),
        .y1       (cannon_y1)
    );

    wall_shape #(
        .WALL_X       (WALL_X),
        .WALL_Y       (WALL_Y),
        .WALL_LAYER_W (WALL_LAYER_W),
        .WALL_H       (WALL_H)
    ) wall_shape_inst (
        .wall_layers_left (wall_layers_left),
        .line_idx         (wall_line_num_6[3:0]),
        .x0               (wall_x0),
        .y0               (wall_y0),
        .x1               (wall_x1),
        .y1               (wall_y1),
        .line_valid       (wall_line_valid)
    );

    bullet_shape bullet_shape_inst (
        .line_num (bullet_line_num_6[3:0]),
        .base_x   ({1'b0, bullet_x}),
        .base_y   ({2'b00, bullet_y}),
        .x0       (bullet_x0),
        .y0       (bullet_y0),
        .x1       (bullet_x1),
        .y1       (bullet_y1)
    );

    // select current line
    always_comb begin
        x0 = 11'd0;
        y0 = 11'd0;
        x1 = 11'd0;
        y1 = 11'd0;
        line_valid = 1'b0;

        if (enable) begin
            if ((line_num >= CANNON_START) && (line_num <= CANNON_END)) begin
                x0 = cannon_x0;
                y0 = cannon_y0;
                x1 = cannon_x1;
                y1 = cannon_y1;
                line_valid = 1'b1;
            end // end if
            else if ((line_num >= WALL_START) && (line_num <= WALL_END)) begin
                x0 = wall_x0;
                y0 = wall_y0;
                x1 = wall_x1;
                y1 = wall_y1;
                line_valid = wall_line_valid;
            end // end else if
            else if ((line_num >= BULLET_START) && (line_num <= BULLET_END)) begin
                x0 = bullet_x0;
                y0 = bullet_y0;
                x1 = bullet_x1;
                y1 = bullet_y1;
                line_valid = bullet_active && game_active;
            end // end else if
        end // end if
    end // end always_comb

endmodule // end module level1_top
