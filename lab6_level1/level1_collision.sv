// level1_collision.sv
// checks bullet collision with player and wall
module level1_collision #(
    parameter int PLAYER_W     = 44,
    parameter int PLAYER_H     = 47,
    parameter int BULLET_W     = 20,
    parameter int BULLET_H     = 20,
    parameter int WALL_X       = 60,
    parameter int WALL_Y       = 280,
    parameter int WALL_LAYER_W = 24,
    parameter int WALL_H       = 80
)(
    input  logic [9:0] player_x,
    input  logic [8:0] player_y,

    input  logic [9:0] bullet_x,
    input  logic [8:0] bullet_y,
    input  logic       bullet_active,

    input  logic [1:0] wall_layers_left,

    output logic       hit_player,
    output logic       hit_wall
);

    // typed constants for Quartus
    localparam logic [10:0] PLAYER_W_11     = PLAYER_W;
    localparam logic [9:0]  PLAYER_H_10     = PLAYER_H;
    localparam logic [10:0] BULLET_W_11     = BULLET_W;
    localparam logic [9:0]  BULLET_H_10     = BULLET_H;
    localparam logic [10:0] WALL_X_11       = WALL_X;
    localparam logic [9:0]  WALL_Y_10       = WALL_Y;
    localparam logic [10:0] WALL_LAYER_W_11 = WALL_LAYER_W;
    localparam logic [9:0]  WALL_H_10       = WALL_H;

    logic [10:0] player_left, player_right;
    logic [9:0]  player_top, player_bottom;

    logic [10:0] bullet_left, bullet_right;
    logic [9:0]  bullet_top, bullet_bottom;

    logic [10:0] wall_left, wall_right;
    logic [9:0]  wall_top, wall_bottom;

    logic [10:0] active_wall_w;

    always_comb begin
        case (wall_layers_left)
            2'd3: active_wall_w = WALL_LAYER_W_11 * 11'd3;
            2'd2: active_wall_w = WALL_LAYER_W_11 * 11'd2;
            2'd1: active_wall_w = WALL_LAYER_W_11;
            default: active_wall_w = 11'd0;
        endcase // end case
    end // end always_comb

    assign player_left   = {1'b0, player_x};
    assign player_right  = {1'b0, player_x} + PLAYER_W_11;
    assign player_top    = {1'b0, player_y};
    assign player_bottom = {1'b0, player_y} + PLAYER_H_10;

    assign bullet_left   = {1'b0, bullet_x};
    assign bullet_right  = {1'b0, bullet_x} + BULLET_W_11;
    assign bullet_top    = {1'b0, bullet_y};
    assign bullet_bottom = {1'b0, bullet_y} + BULLET_H_10;

    assign wall_left     = WALL_X_11;
    assign wall_right    = WALL_X_11 + active_wall_w;
    assign wall_top      = WALL_Y_10;
    assign wall_bottom   = WALL_Y_10 + WALL_H_10;

    always_comb begin
        hit_player = 1'b0;
        hit_wall   = 1'b0;

        if (bullet_active) begin
            hit_player = (bullet_left   < player_right)  &&
                         (bullet_right  > player_left)   &&
                         (bullet_top    < player_bottom) &&
                         (bullet_bottom > player_top);

            hit_wall = (wall_layers_left != 2'd0) &&
                       (bullet_left   < wall_right)  &&
                       (bullet_right  > wall_left)   &&
                       (bullet_top    < wall_bottom) &&
                       (bullet_bottom > wall_top);
        end // end if
    end // end always_comb

endmodule // end module level1_collision
