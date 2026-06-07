module lilcat_shape #(
    parameter int SPRITE_W = 80,
    parameter int SPRITE_H = 85,
    parameter int SCALE    = 2,   // Shrink the cat by a factor of 2
    parameter int DRAW_W   = 40,  // 80 / 2
    parameter int DRAW_H   = 42   // 85 / 2
)(
    input  logic        clk,
    input  logic [9:0]  x,        // 10-bit X coordinate
    input  logic [8:0]  y,        // 9-bit Y coordinate
    input  logic [9:0]  pos_x,
    input  logic [8:0]  pos_y,
    output logic        pixel_on,
    output logic [7:0]  r, g, b
);

    logic in_bounds;
    assign in_bounds = (x >= pos_x) && (x < pos_x + DRAW_W) &&
                       (y >= pos_y) && (y < pos_y + DRAW_H);

    logic [$clog2(SPRITE_H)-1:0] rom_y;
    logic [$clog2(SPRITE_W)-1:0] rom_x;
    
    assign rom_y = (y - pos_y) * SCALE;
    assign rom_x = (x - pos_x) * SCALE;

    logic [SPRITE_W-1:0] cat_row;
    
    // Feed the scaled Y coordinate to the ROM
    lilcat_rom cat_rom_inst (.address(rom_y), .clock(clk), .q(cat_row));

    logic cat_bit;
    // Extract the scaled X coordinate bit from that row
    assign cat_bit = in_bounds ? cat_row[SPRITE_W - 1 - rom_x] : 1'b0;

    assign pixel_on = in_bounds && cat_bit;

    always_comb begin
        if (pixel_on)
            {r, g, b} = {8'hFF, 8'hA2, 8'h38}; 
        else
            {r, g, b} = {8'hFF, 8'hFF, 8'hFF}; // Background
    end

endmodule