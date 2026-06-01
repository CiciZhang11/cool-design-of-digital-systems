// bullet_update_pos.sv
// This module controls one bullet from the cannon
// The bullet moves from right to left and respawns after hit or leaving screen

module bullet_update_pos #(
    parameter int SCREEN_W     = 320,
    parameter int BULLET_W     = 6,
    parameter int START_X      = 300,
    parameter int START_Y      = 160,
    parameter int BULLET_SPEED = 4,
    parameter int COOLDOWN_MAX = 20
)(
    input  logic clk,
    input  logic reset,
    input  logic update_en,

    input  logic enable,
    input  logic hit_wall,
    input  logic hit_player,
    input  logic [8:0] spawn_y,

    output logic [9:0] bullet_x,
    output logic [8:0] bullet_y,
    output logic       bullet_active
);

    // Width-matched constants
    localparam logic [9:0] START_X_10   = START_X;
    localparam logic [8:0] START_Y_9    = START_Y;
    localparam logic [9:0] SPEED_10     = BULLET_SPEED;
    localparam logic [$clog2(COOLDOWN_MAX+1)-1:0] COOLDOWN_VALUE = COOLDOWN_MAX;

    // Wait time before the bullet respawns
    logic [$clog2(COOLDOWN_MAX+1)-1:0] cooldown;

    always_ff @(posedge clk) begin
        if (reset) begin
            // Start with one active bullet
            bullet_x      <= START_X_10;
            bullet_y      <= START_Y_9;
            bullet_active <= 1'b1;
            cooldown      <= '0;
        end
        else if (update_en) begin
            if (!enable) begin
                // Turn off the bullet when the level is not active
                bullet_active <= 1'b0;
                cooldown      <= COOLDOWN_VALUE;
            end
            else if (bullet_active) begin
                // Bullet disappears if it hits something or leaves the screen
                if (hit_wall || hit_player || (bullet_x <= SPEED_10)) begin
                    bullet_active <= 1'b0;
                    cooldown      <= COOLDOWN_VALUE;
                end
                else begin
                    // Move bullet to the left
                    bullet_x <= bullet_x - SPEED_10;
                end
            end
            else begin
                if (cooldown != '0) begin
                    cooldown <= cooldown - 1'b1;
                end
                else begin
                    // Respawn the bullet from the cannon side
                    bullet_x      <= START_X_10;
                    bullet_y      <= spawn_y;
                    bullet_active <= 1'b1;
                end
            end
        end
    end

endmodule