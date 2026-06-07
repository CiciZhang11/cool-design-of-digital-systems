// level1_top.sv
// Level 1 controller
// Handles game update, line drawing, lilcat drawing, and framebuffer writes

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
    input  logic        enable,

    input  logic        left,
    input  logic        right,
    input  logic        up,
    input  logic        a,

    output logic [10:0] fb_x,
    output logic [10:0] fb_y,
    output logic        fb_pixel_color,
    output logic        fb_pixel_write,

    output logic [9:0]  player_x,
    output logic [8:0]  player_y,

    output logic [9:0]  bullet_x,
    output logic [8:0]  bullet_y,
    output logic        bullet_active,

    output logic [1:0]  wall_layers_left,
    output logic        hit_player,
    output logic        hit_wall,
    output logic        player_dead,
    output logic        level_clear
);

    // ------------------------------------------------------------
    // Line ranges
    // ------------------------------------------------------------

    localparam logic [5:0] CANNON_START = 6'd0;
    localparam logic [5:0] CANNON_END   = 6'd7;

    localparam logic [5:0] WALL_START   = 6'd8;
    localparam logic [5:0] WALL_END     = 6'd19;

    localparam logic [5:0] BULLET_START = 6'd20;
    localparam logic [5:0] BULLET_END   = 6'd24;

    localparam logic [5:0] LAST_LINE    = 6'd24;

    localparam logic [8:0] BULLET_START_Y_9 = BULLET_START_Y;

    // ------------------------------------------------------------
    // Game control
    // ------------------------------------------------------------

    logic update_en;
    logic game_active;
    logic bullet_enable;
    logic jump_button;

    logic facing_left;
    logic on_ground;
    logic [1:0] player_frame;

    assign game_active   = enable && !level_clear;
    assign bullet_enable = game_active;
    assign jump_button   = up || a;

    // ------------------------------------------------------------
    // Player update
    // ------------------------------------------------------------

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
        .LEFT_LIMIT     (136),
        .RIGHT_LIMIT    (452)
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

    // Facing direction and walking frame
    always_ff @(posedge clk) begin
        if (reset) begin
            facing_left  <= 1'b0;
            player_frame <= 2'd0;
        end
        else if (update_en && game_active) begin
            if (left && !right) begin
                facing_left  <= 1'b1;
                player_frame <= player_frame + 2'd1;
            end
            else if (right && !left) begin
                facing_left  <= 1'b0;
                player_frame <= player_frame + 2'd1;
            end
        end
    end  // facing direction and frame

    // ------------------------------------------------------------
    // Bullet update
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // Collision
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // Wall controller
    // ------------------------------------------------------------

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

    // Player dead debug flag
    always_ff @(posedge clk) begin
        if (reset) begin
            player_dead <= 1'b0;
        end
        else if (enable && update_en && hit_player) begin
            player_dead <= 1'b1;
        end
    end  // player dead debug

    // ------------------------------------------------------------
    // Shape line endpoints
    // ------------------------------------------------------------

    logic [5:0] line_num;

    logic [10:0] level_x0;
    logic [10:0] level_y0;
    logic [10:0] level_x1;
    logic [10:0] level_y1;
    logic        level_line_valid;

    logic [10:0] cannon_x0, cannon_y0, cannon_x1, cannon_y1;
    logic [10:0] wall_x0, wall_y0, wall_x1, wall_y1;
    logic [10:0] bullet_x0, bullet_y0, bullet_x1, bullet_y1;

    logic wall_line_valid;

    logic [5:0] wall_line_num_6;
    logic [5:0] bullet_line_num_6;

    assign wall_line_num_6   = line_num - WALL_START;
    assign bullet_line_num_6 = line_num - BULLET_START;

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

    // Select current line
    always_comb begin
        level_x0 = 11'd0;
        level_y0 = 11'd0;
        level_x1 = 11'd0;
        level_y1 = 11'd0;
        level_line_valid = 1'b0;

        if (enable) begin
            if ((line_num >= CANNON_START) && (line_num <= CANNON_END)) begin
                level_x0 = cannon_x0;
                level_y0 = cannon_y0;
                level_x1 = cannon_x1;
                level_y1 = cannon_y1;
                level_line_valid = 1'b1;
            end
            else if ((line_num >= WALL_START) && (line_num <= WALL_END)) begin
                level_x0 = wall_x0;
                level_y0 = wall_y0;
                level_x1 = wall_x1;
                level_y1 = wall_y1;
                level_line_valid = wall_line_valid;
            end
            else if ((line_num >= BULLET_START) && (line_num <= BULLET_END)) begin
                level_x0 = bullet_x0;
                level_y0 = bullet_y0;
                level_x1 = bullet_x1;
                level_y1 = bullet_y1;
                level_line_valid = bullet_active && game_active;
            end
        end
    end  // select current line

    // ------------------------------------------------------------
    // Line drawer
    // ------------------------------------------------------------

    logic line_reset;
    logic line_done;
    logic [10:0] line_x;
    logic [10:0] line_y;

    line_drawer lines (
        .clk   (clk),
        .reset (line_reset),
        .x0    (level_x0),
        .y0    (level_y0),
        .x1    (level_x1),
        .y1    (level_y1),
        .x     (line_x),
        .y     (line_y),
        .done  (line_done)
    );

    // ------------------------------------------------------------
    // Lilcat MIF drawer
    // ------------------------------------------------------------

    logic        lilcat_start;
    logic        lilcat_done;
    logic        lilcat_pixel_write;
    logic [10:0] lilcat_write_x;
    logic [10:0] lilcat_write_y;
    logic        lilcat_pixel_color;

    lilcat_shape #(
        .SPRITE_W  (88),
        .SPRITE_H  (93),
        .DISPLAY_W (44),
        .DISPLAY_H (47)
    ) lilcat_shape_inst (
        .clk         (clk),
        .reset       (reset),
        .start       (lilcat_start),
        .player_x    (player_x),
        .player_y    (player_y),
        .pixel_write (lilcat_pixel_write),
        .write_x     (lilcat_write_x),
        .write_y     (lilcat_write_y),
        .pixel_color (lilcat_pixel_color),
        .done        (lilcat_done)
    );

    // ------------------------------------------------------------
    // Draw FSM
    // ------------------------------------------------------------

    localparam logic [2:0] S_CLEAR        = 3'd0;
    localparam logic [2:0] S_LINE_RESET   = 3'd1;
    localparam logic [2:0] S_DRAW_LINE    = 3'd2;
    localparam logic [2:0] S_CAT_START    = 3'd3;
    localparam logic [2:0] S_DRAW_CAT     = 3'd4;
    localparam logic [2:0] S_WAIT         = 3'd5;
    localparam logic [2:0] S_UPDATE       = 3'd6;

    localparam logic [18:0] WAIT_MAX = 19'd500000;

    logic [2:0]  state;
    logic [10:0] clear_x;
    logic [8:0]  clear_y;
    logic [18:0] wait_count;

    always_ff @(posedge clk) begin
        if (reset) begin
            state      <= S_CLEAR;
            clear_x    <= 11'd0;
            clear_y    <= 9'd0;
            line_num   <= 6'd0;
            wait_count <= 19'd0;
        end
        else begin
            case (state)

                S_CLEAR: begin
                    if (clear_x == 11'd639) begin
                        clear_x <= 11'd0;

                        if (clear_y == 9'd479) begin
                            clear_y  <= 9'd0;
                            line_num <= 6'd0;
                            state    <= S_LINE_RESET;
                        end
                        else begin
                            clear_y <= clear_y + 9'd1;
                        end
                    end
                    else begin
                        clear_x <= clear_x + 11'd1;
                    end
                end  // S_CLEAR

                S_LINE_RESET: begin
                    state <= S_DRAW_LINE;
                end  // S_LINE_RESET

                S_DRAW_LINE: begin
                    if (!level_line_valid || line_done) begin
                        if (line_num == LAST_LINE) begin
                            state <= S_CAT_START;
                        end
                        else begin
                            line_num <= line_num + 6'd1;
                            state    <= S_LINE_RESET;
                        end
                    end
                end  // S_DRAW_LINE

                S_CAT_START: begin
                    state <= S_DRAW_CAT;
                end  // S_CAT_START

                S_DRAW_CAT: begin
                    if (lilcat_done) begin
                        wait_count <= 19'd0;
                        state      <= S_WAIT;
                    end
                end  // S_DRAW_CAT

                S_WAIT: begin
                    if (wait_count == WAIT_MAX) begin
                        state <= S_UPDATE;
                    end
                    else begin
                        wait_count <= wait_count + 19'd1;
                    end
                end  // S_WAIT

                S_UPDATE: begin
                    state <= S_CLEAR;
                end  // S_UPDATE

                default: begin
                    state <= S_CLEAR;
                end  // default

            endcase
        end
    end  // draw FSM

    // ------------------------------------------------------------
    // Framebuffer mux
    // ------------------------------------------------------------

    always_comb begin
        fb_x = 11'd0;
        fb_y = 11'd0;
        fb_pixel_color = 1'b0;
        fb_pixel_write = 1'b0;

        line_reset = 1'b0;
        update_en = 1'b0;
        lilcat_start = 1'b0;

        case (state)

            S_CLEAR: begin
                fb_x = clear_x;
                fb_y = {2'b00, clear_y};
                fb_pixel_color = 1'b0;
                fb_pixel_write = 1'b1;
                line_reset = 1'b1;
            end  // S_CLEAR

            S_LINE_RESET: begin
                line_reset = 1'b1;
            end  // S_LINE_RESET

            S_DRAW_LINE: begin
                fb_x = line_x;
                fb_y = line_y;
                fb_pixel_color = 1'b1;
                fb_pixel_write = level_line_valid;
            end  // S_DRAW_LINE

            S_CAT_START: begin
                lilcat_start = 1'b1;
            end  // S_CAT_START

            S_DRAW_CAT: begin
                fb_x = lilcat_write_x;
                fb_y = lilcat_write_y;
                fb_pixel_color = lilcat_pixel_color;
                fb_pixel_write = lilcat_pixel_write;
            end  // S_DRAW_CAT

            S_UPDATE: begin
                update_en = 1'b1;
            end  // S_UPDATE

            default: begin
                fb_pixel_write = 1'b0;
            end  // default

        endcase
    end  // framebuffer mux

endmodule  // level1_top