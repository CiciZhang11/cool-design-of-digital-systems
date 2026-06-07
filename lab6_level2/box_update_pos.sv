module box_update_pos #(
    parameter int START_X = 300,
    parameter int START_Y = 350,  // Assuming 350 is ground level for the box
    parameter int SPEED   = 2     // Should match the player's walking speed
)(
    input  logic clk,
    input  logic reset,
    input  logic update_en,  // 1-tick pulse per frame (e.g., Vertical Sync)

    input  logic push_left,  // High when player collides and pushes left
    input  logic push_right, // High when player collides and pushes right

    output logic [9:0] box_x,
    output logic [8:0] box_y
);

    always_ff @(posedge clk) begin
        if (reset) begin
            box_x <= START_X;
            box_y <= START_Y; 
        end else if (update_en) begin
            if (push_right) begin
                box_x <= box_x + SPEED;
            end else if (push_left) begin
                box_x <= box_x - SPEED;
            end
        end
    end

endmodule