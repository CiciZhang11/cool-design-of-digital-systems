module elevator_shape #(
    parameter int ELEVATOR_W = 60,
    parameter int ELEVATOR_H = 15
)(
    input  logic [9:0] x,          // 10-bit X coordinate
    input  logic [8:0] y,          // 9-bit Y coordinate (Fixed!)
    input  logic [9:0] pos_x,      
    input  logic [8:0] pos_y,      
    
    output logic       pixel_on,
    output logic [7:0] r, g, b
);

    assign pixel_on = (x >= pos_x) && (x < pos_x + ELEVATOR_W) &&
                      (y >= pos_y) && (y < pos_y + ELEVATOR_H);

    always_comb begin
        if (pixel_on)
            {r, g, b} = {8'h00, 8'hFF, 8'h00}; // Green Elevator
        else
            {r, g, b} = {8'h00, 8'h00, 8'h00};
    end

endmodule