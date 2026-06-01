// player_update_pos.sv
// This module updates the player position
// The player can move left, move right, and jump
// player_x and player_y mean the top-left corner of the player

module player_update_pos #(
    parameter int SCREEN_W  = 320,
    parameter int SCREEN_H  = 240,
    parameter int PLAYER_W  = 16,
    parameter int PLAYER_H  = 24,
    parameter int START_X   = 150,
    parameter int GROUND_Y  = 150,
    parameter int MOVE_STEP = 2,
    parameter int GRAVITY   = 1,
    parameter int JUMP_VEL  = -9
)(
    input  logic clk,
    input  logic reset,
    input  logic update_en,

    input  logic left,
    input  logic right,
    input  logic up,
    input  logic a,

    output logic [9:0] player_x,
    output logic [8:0] player_y,
    output logic       facing_left,
    output logic       on_ground,
    output logic [1:0] frame_num
);

    localparam logic [9:0] START_X_10      = START_X;
    localparam logic [8:0] GROUND_Y_9      = GROUND_Y;
    localparam logic [9:0] MOVE_STEP_10    = MOVE_STEP;
    localparam logic [9:0] MAX_PLAYER_X_10 = SCREEN_W - PLAYER_W;
    localparam signed [7:0] JUMP_VEL_8     = JUMP_VEL;
    localparam signed [7:0] GRAVITY_8      = GRAVITY;

    logic signed [7:0] y_vel; // vertical speed for jumping
    logic [3:0] anim_count; // slow down the walking animation

    wire jump_pressed = up | a;
    wire moving       = left ^ right;

    // jump and gravity calculation
    wire signed [10:0] player_y_signed = $signed({2'b00, player_y});
    wire signed [10:0] y_vel_signed    = $signed(y_vel);
    wire signed [10:0] next_y_signed   = player_y_signed + y_vel_signed;

    always_ff @(posedge clk) begin
        if (reset) begin
            player_x    <= START_X_10;
            player_y    <= GROUND_Y_9;
            y_vel       <= 8'sd0;
            facing_left <= 1'b0;
            on_ground   <= 1'b1;
            frame_num   <= 2'd0;
            anim_count  <= 4'd0;
        end
        else if (update_en) begin
            // Move the player left
            if (left && !right) begin
                facing_left <= 1'b1;
                if (player_x > MOVE_STEP_10)
                    player_x <= player_x - MOVE_STEP_10;
                else
                    player_x <= 10'd0;
            end
            // Move the player right
            else if (right && !left) begin
                facing_left <= 1'b0;
                if (player_x < (MAX_PLAYER_X_10 - MOVE_STEP_10))
                    player_x <= player_x + MOVE_STEP_10;
                else
                    player_x <= MAX_PLAYER_X_10;
            end

            // Start the jump when the player is on the ground
            if (on_ground && jump_pressed) begin
                y_vel     <= JUMP_VEL_8;
                on_ground <= 1'b0;
            end
            // Apply gravity while the player is in the air
            else if (!on_ground) begin
                if (next_y_signed >= $signed({2'b00, GROUND_Y_9})) begin
                    // If the player reaches the ground, stop falling
                    player_y  <= GROUND_Y_9;
                    y_vel     <= 8'sd0;
                    on_ground <= 1'b1;
                end
                else begin
                    // Otherwise, keep updating vertical position
                    player_y  <= next_y_signed[8:0];
                    y_vel     <= y_vel + GRAVITY_8;
                    on_ground <= 1'b0;
                end
            end
            else begin
                // Keep the player on the ground when not jumping
                player_y <= GROUND_Y_9;
                y_vel    <= 8'sd0;
            end

            // Update walking animation when the player is moving on the ground
            if (moving && on_ground) begin
                anim_count <= anim_count + 4'd1;
                if (anim_count == 4'd7) begin
                    anim_count <= 4'd0;
                    if (frame_num == 2'd2)
                        frame_num <= 2'd1;
                    else
                        frame_num <= frame_num + 2'd1;
                end
            end
            else begin
                // Use the standing frame when the player is not moving
                frame_num  <= 2'd0;
                anim_count <= 4'd0;
            end
        end
    end

endmodule