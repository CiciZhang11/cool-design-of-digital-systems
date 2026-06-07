// this draws a start_page with our small character on the top, and a text "START"
// on the bottom of the page.
module end_page (
    input  logic        clk, reset,
    input  logic [9:0]  x,
    input  logic [8:0]  y,
    output logic [7:0]  r, g, b
);

    // screen size
    localparam int SCREEN_W = 320;
    localparam int SCREEN_H = 240;

    // lilcat sprite dimensions
    localparam int CAT_W= 80;
    localparam int CAT_H= 85;
    localparam int CAT_DEPTH = CAT_W * CAT_H;  // = 6800

    // start text sprite dimensions
    localparam int TXT_W= 276;
    localparam int TXT_H= 111;
    localparam int TXT_DEPTH = TXT_W * TXT_H;  // = 30636

    // Vertical gap between cat bottom and text top
    localparam int GAP = 10;

    // Total block height, vertically centered
    localparam int BLOCK_H = CAT_H + GAP + TXT_H;   // 206
    localparam int CAT_Y= (SCREEN_H - BLOCK_H) / 2;     // 17
    localparam int TXT_Y= CAT_Y + CAT_H + GAP;    // 112

    // Horizontally centered
    localparam int CAT_X= (SCREEN_W - CAT_W) / 2;   // 120
    localparam int TXT_X= (SCREEN_W - TXT_W) / 2; // 22

  
   // Check the edge
    logic in_cat, in_txt;
    assign in_cat = (x >= CAT_X) && (x < CAT_X + CAT_W) &&
                    (y >= CAT_Y) && (y < CAT_Y + CAT_H);
    assign in_txt = (x >= TXT_X) && (x < TXT_X + TXT_W) &&
                    (y >= TXT_Y) && (y < TXT_Y + TXT_H);

   // ROM address = row index only
    logic [$clog2(CAT_H)-1:0] cat_addr;
    logic [$clog2(TXT_H)-1:0] txt_addr;
    
    assign cat_addr = (y -CAT_Y);
    assign txt_addr = (y -TXT_Y);

    logic [CAT_W-1:0] cat_row;
    logic [TXT_W-1:0] txt_row;
    
    lilcat_rom cat_rom_inst (.address(cat_addr), .clock(clk), .q(cat_row));
    end_rom  txt_rom_inst (.address(txt_addr), .clock(clk), .q(txt_row));
    
    // Pick the specific pixel bit
    logic cat_bit, txt_bit;
    assign cat_bit = in_cat ? cat_row[CAT_W - 1 - (x - CAT_X)] : 1'b0;
    assign txt_bit = in_txt ? txt_row[TXT_W - 1 - (x - TXT_X)] : 1'b0;

    // Color
    always_comb begin
        if (in_cat && cat_bit)
            {r, g, b} = {8'hFF, 8'hA2, 8'h38};  // lilcat fill: FFA238
        else if (in_txt && txt_bit)
            {r, g, b} = {8'h00, 8'h00, 8'h00};  // start text: black ink
        else
            {r, g, b} = {8'hFF, 8'hFF, 8'hFF};  // background: white
    end

endmodule  // start_page