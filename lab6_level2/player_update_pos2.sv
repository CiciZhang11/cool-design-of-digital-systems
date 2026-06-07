module player_update_pos2 #(
    // Player Dimensions (from lilcat_shape)
    parameter int P_W = 44,
    parameter int P_H = 47,
    // Box Dimensions (must match box_shape)
    parameter int B_W = 40,
    parameter int B_H = 50,
    // Elevator Dimensions (must match elevator_shape)
    parameter int E_W = 60,
    parameter int E_H = 15,
    // Shelf (right-side platform) Dimensions
    parameter int S_W = 80,
    parameter int S_H = 4,
    // Game Physics Constants
    parameter int GROUND_Y  = 400,
    parameter int SPEED     = 2,
    parameter int JUMP_POWER = 9,
    parameter int GRAVITY   = 0.5,
    // Landing snap tolerance (px): player feet must be within this many pixels
    // ABOVE the surface top to land on it. Prevents walking-into-side bugs.
    parameter int SNAP_TOL  = 4
)(
    input  logic clk,
    input  logic reset,
    input  logic update_en,  // 1-tick pulse per frame

    // Player Controls
    input  logic btn_left,
    input  logic btn_right,
    input  logic btn_jump,

    // Coordinates of other objects for collision
    input  logic [9:0] box_x,
    input  logic [8:0] box_y,
    input  logic [9:0] elevator_x,
    input  logic [8:0] elevator_y,
    // Right-side shelf (platform next to the door)
    input  logic [9:0] shelf_x,
    input  logic [8:0] shelf_y,

    // Outputs
    output logic [9:0] player_x,
    output logic [8:0] player_y,
    output logic       push_left,
    output logic       push_right
);

    logic signed [9:0] y_velocity;
    logic [8:0] current_floor_y;
    logic is_grounded;

    // --- DYNAMIC FLOOR CALCULATION ---
    // A surface only counts as a floor if the player is approaching from ABOVE.
    // The SNAP_TOL check (player_y + P_H <= surface_y + SNAP_TOL) ensures the
    // player's feet are near or above the surface top, preventing the player
    // from "teleporting" onto a box or elevator by walking into its side.
    always_comb begin
        if ((player_x + P_W > box_x) && (player_x < box_x + B_W) &&
            (player_y + P_H <= box_y + SNAP_TOL))
            current_floor_y = box_y;

        else if ((player_x + P_W > elevator_x) && (player_x < elevator_x + E_W) &&
                 (player_y + P_H <= elevator_y + SNAP_TOL))
            current_floor_y = elevator_y;

        else if ((player_x + P_W > shelf_x) && (player_x < shelf_x + S_W) &&
                 (player_y + P_H <= shelf_y + SNAP_TOL))
            current_floor_y = shelf_y;

        else
            current_floor_y = GROUND_Y;
    end

    // Check if player's feet are touching the current active floor
    //assign is_grounded = (player_y + P_H >= current_floor_y);

    always_ff @(posedge clk) begin
        if (reset) begin
            player_x   <= 10'd50;
            player_y   <= GROUND_Y - P_H;
            y_velocity <= 0;
            push_left  <= 0;
            push_right <= 0;
            is_grounded <= 1'b1;
        end else if (update_en) begin
            
            // --- 1. HORIZONTAL MOVEMENT & PUSHING ---
            push_left  <= 1'b0;
            push_right <= 1'b0;

            if (btn_right) begin
                // Check if walking into the left side of the box
                if ((player_x + P_W >= box_x) && (player_x < box_x) && (player_y + P_H > box_y)) begin
                    push_right <= 1'b1; // Tell box to move!
                    player_x   <= player_x + SPEED;
                end else if (player_x + P_W < 640) begin
                    player_x <= player_x + SPEED;
                end
            end 
            else if (btn_left) begin
                // Check if walking into the right side of the box
                if ((player_x <= box_x + B_W) && (player_x > box_x) && (player_y + P_H > box_y)) begin
                    push_left <= 1'b1; // Tell box to move!
                    player_x  <= player_x - SPEED;
                end else if (player_x > 0) begin
                    player_x <= player_x - SPEED;
                end
            end

            // --- 2. VERTICAL MOVEMENT (GRAVITY & JUMP) ---
            if (is_grounded) begin
                // Lock player to the surface of whatever they are standing on
                player_y   <= current_floor_y - P_H;
                y_velocity <= 0;
                
                // Allow jump only if on the ground/box/elevator
                if (btn_jump) begin
                    y_velocity <= -JUMP_POWER; // Shoot upwards
                    is_grounded <= 1'b0; // not ground anymore
                end
            end else begin
                // In the air: apply gravity to velocity, update Y position
                y_velocity <= y_velocity + GRAVITY;
                
                // Prevent falling through the floor on the next frame
                if ($signed({1'b0, player_y}) + y_velocity + P_H > $signed({1'b0, current_floor_y})) begin
                    player_y   <= current_floor_y - P_H;
                    y_velocity <= 0;
                    is_grounded <= 1'b1;
                end else begin
                    player_y <= $unsigned($signed({1'b0, player_y}) + y_velocity);
                end
            end
            
        end
    end
endmodule