module lilcat_shape #(
    parameter SPRITE_W = 88,   // original ROM dimensions
    parameter SPRITE_H = 93,
    parameter DISPLAY_W = 44,  // how big to draw it on screen (can differ!)
    parameter DISPLAY_H = 47
)(
    input  logic        clk,
    input  logic [9:0]  x, y,          // current VGA pixel
    input  logic [9:0]  pos_x,         // top-left position on screen
    input  logic [8:0]  pos_y,
    output logic        pixel_on,      // is this pixel part of the sprite?
    output logic [7:0]  r, g, b
);
// to move it
//lilcat_shape #(.DISPLAY_W(24), .DISPLAY_H(25)) cat_game (
//    .clk, .x, .y,
//    .pos_x(char_x), .pos_y(char_y),   // driven by pos_update module
//    .pixel_on(cat_on), .r(cat_r), .g(cat_g), .b(cat_b)
//);

    // Is the current pixel inside the drawn bounding box?
    logic in_bounds;
    assign in_bounds = (x >= pos_x) && (x < pos_x + DISPLAY_W) &&
                       (y >= pos_y) && (y < pos_y + DISPLAY_H);

    // Map screen pixel back to ROM pixel (scale down by ratio)
    // e.g. DISPLAY_W=44, SPRITE_W=88 → every 1 screen px = 2 ROM px
    logic [$clog2(SPRITE_W)-1:0] rom_col;
    logic [$clog2(SPRITE_H)-1:0] rom_row;
    assign rom_col = (x - pos_x) * SPRITE_W / DISPLAY_W;
    assign rom_row = (y - pos_y) * SPRITE_H / DISPLAY_H;

    // ROM address
    logic [$clog2(SPRITE_W * SPRITE_H)-1:0] addr;
    assign addr = rom_row * SPRITE_W + rom_col;

    // ROM instance — one shared ROM, reused everywhere
    logic rom_bit;
    lilcat_rom cat_rom_inst (
        .address (addr),
        .clock   (clk),
        .q       (rom_bit)
    );

    assign pixel_on = in_bounds && rom_bit;

    always_comb begin
        if (in_bounds && rom_bit)
            {r, g, b} = {8'hFF, 8'hA2, 8'h38};  // FFA238
        else
            {r, g, b} = {8'hFF, 8'hFF, 8'hFF};  // background
    end

endmodule