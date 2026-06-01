// bullet_update_pos.sv
// Updates one cannon bullet moving from right to left.
// Coordinate convention: bullet_x/bullet_y are the top-left corner of the bullet shape.

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

    localparam logic [9:0] START_X_10   = START_X;
    localparam logic [8:0] START_Y_9    = START_Y;
    localparam logic [9:0] SPEED_10     = BULLET_SPEED;
    localparam logic [$clog2(COOLDOWN_MAX+1)-1:0] COOLDOWN_VALUE = COOLDOWN_MAX;

    logic [$clog2(COOLDOWN_MAX+1)-1:0] cooldown;

    always_ff @(posedge clk) begin
        if (reset) begin
            bullet_x      <= START_X_10;
            bullet_y      <= START_Y_9;
            bullet_active <= 1'b1;
            cooldown      <= '0;
        end
        else if (update_en) begin
            if (!enable) begin
                bullet_active <= 1'b0;
                cooldown      <= COOLDOWN_VALUE;
            end
            else if (bullet_active) begin
                if (hit_wall || hit_player || (bullet_x <= SPEED_10)) begin
                    bullet_active <= 1'b0;
                    cooldown      <= COOLDOWN_VALUE;
                end
                else begin
                    bullet_x <= bullet_x - SPEED_10;
                end
            end
            else begin
                if (cooldown != '0) begin
                    cooldown <= cooldown - 1'b1;
                end
                else begin
                    bullet_x      <= START_X_10;
                    bullet_y      <= spawn_y;
                    bullet_active <= 1'b1;
                end
            end
        end
    end

endmodule
