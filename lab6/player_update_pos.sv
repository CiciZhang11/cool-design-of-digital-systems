// player_update_pos.sv
// updates the level 1 player position
// player_x/player_y are the top-left corner
// player is limited between the wall and the cannon
module player_update_pos #(
    parameter int SCREEN_W       = 640,
    parameter int SCREEN_H       = 480,
    parameter int PLAYER_W       = 44,
    parameter int PLAYER_H       = 47,
    parameter int PLAYER_START_X = 280,
    parameter int FLOOR_Y        = 360,

    parameter int MOVE_STEP      = 6,
    parameter int JUMP_VEL_INIT  = 14,
    parameter int GRAVITY        = 1,

    // Level 1 movement bounds
    // Wall is around x = 60~132
    // Cannon starts around x = 500
    parameter int LEFT_LIMIT     = 140,
    parameter int RIGHT_LIMIT    = 448
)(
    input  logic clk,
    input  logic reset,
    input  logic update_en,

    input  logic enable,
    input  logic move_left,
    input  logic move_right,
    input  logic jump,

    output logic [9:0] player_x,
    output logic [8:0] player_y,
    output logic       on_ground
);

    // ground position for top-left y
    localparam logic [8:0] PLAYER_GROUND_Y_9 = FLOOR_Y - PLAYER_H;

    // typed constants for Quartus
    localparam logic [9:0] START_X_10 = PLAYER_START_X;
    localparam logic [9:0] MOVE_10    = MOVE_STEP;

    localparam logic [9:0] LEFT_BOUND  = LEFT_LIMIT;
    localparam logic [9:0] RIGHT_BOUND = RIGHT_LIMIT;

    localparam logic signed [8:0] JUMP_VEL_INIT_9 = JUMP_VEL_INIT;
    localparam logic signed [8:0] GRAVITY_9       = GRAVITY;

    logic signed [8:0] y_vel;

    always_ff @(posedge clk) begin
        if (reset) begin
            player_x  <= START_X_10;
            player_y  <= PLAYER_GROUND_Y_9;
            y_vel     <= 9'sd0;
            on_ground <= 1'b1;
        end // end if
        else if (update_en) begin
            if (enable) begin
                // Move left
                if (move_left && !move_right) begin
                    if (player_x > LEFT_BOUND + MOVE_10) begin
                        player_x <= player_x - MOVE_10;
                    end // end if
                    else begin
                        player_x <= LEFT_BOUND;
                    end // end else
                end // end if

                // Move right
                else if (move_right && !move_left) begin
                    if (player_x < RIGHT_BOUND - MOVE_10) begin
                        player_x <= player_x + MOVE_10;
                    end // end if
                    else begin
                        player_x <= RIGHT_BOUND;
                    end // end else
                end // end else if

                // Start jump
                if (jump && on_ground) begin
                    y_vel     <= -JUMP_VEL_INIT_9;
                    on_ground <= 1'b0;
                end // end if

                // Gravity
                if (!on_ground) begin
                    if (($signed({1'b0, player_y}) + y_vel) >= $signed({1'b0, PLAYER_GROUND_Y_9})) begin
                        player_y  <= PLAYER_GROUND_Y_9;
                        y_vel     <= 9'sd0;
                        on_ground <= 1'b1;
                    end // end if
                    else begin
                        player_y <= player_y + y_vel;
                        y_vel    <= y_vel + GRAVITY_9;
                    end // end else
                end // end if
            end // end if
        end // end else if
    end // end always_ff

endmodule // end module player_update_pos
