module elevator_update_pos #(
    parameter int START_X = 500, // Fixed X position on the right side
    parameter int MIN_Y   = 150, // Highest point (Remember: 0 is the top of the screen)
    parameter int MAX_Y   = 350, // Lowest point (Ground level)
    parameter int SPEED   = 1    // Elevator speed
)(
    input  logic clk,
    input  logic reset,
    input  logic update_en,

    output logic [9:0] elevator_x,
    output logic [8:0] elevator_y
);

    logic moving_down; // 1 = moving down (+Y), 0 = moving up (-Y)

    always_ff @(posedge clk) begin
        if (reset) begin
            elevator_x  <= START_X; 
            elevator_y  <= MAX_Y;   // Start at the bottom
            moving_down <= 1'b0;    // Start by moving up
        end else if (update_en) begin
            
            if (moving_down) begin
                if (elevator_y + SPEED >= MAX_Y) begin
                    elevator_y  <= MAX_Y;
                    moving_down <= 1'b0; // Switch direction to UP
                end else begin
                    elevator_y <= elevator_y + SPEED;
                end
            end else begin
                if (elevator_y <= MIN_Y + SPEED) begin
                    elevator_y  <= MIN_Y;
                    moving_down <= 1'b1; // Switch direction to DOWN
                end else begin
                    elevator_y <= elevator_y - SPEED;
                end
            end
            
        end
    end

endmodule