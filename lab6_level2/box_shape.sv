module box_shape #(
    parameter int BOX_W = 40,
    parameter int BOX_H = 50
)(
    input  logic [9:0] x,          // 10-bit X coordinate
    input  logic [8:0] y,          // 9-bit Y coordinate (Fixed!)
    input  logic [9:0] pos_x,      
    input  logic [8:0] pos_y,      
    
    output logic       pixel_on,   
    output logic [7:0] r, g, b
);

    // Check if current (x,y) falls within the box's bounding rectangle
    assign pixel_on = (x >= pos_x) && (x < pos_x + BOX_W) &&
                      (y >= pos_y) && (y < pos_y + BOX_H);

    always_comb begin
        if (pixel_on)
            {r, g, b} = {8'hA0, 8'h20, 8'hF0}; // Purple
        else
            {r, g, b} = {8'h00, 8'h00, 8'h00}; // Background
    end

endmodule