// vga_timer.sv
// Pure timing generator for 640x480 at 60Hz. No memory attached.
module vga_timer (
    input  logic clk50, reset,
    output logic [9:0] x,
    output logic [8:0] y,
    output logic VGA_HS, VGA_VS, VGA_BLANK_n, VGA_CLK, VGA_SYNC_n
);

    parameter HACTIVE = 1280, HFRONT_PORCH = 32, HSYNC = 192, HBACK_PORCH = 96, HTOTAL = 1600;
    parameter VACTIVE = 480,  VFRONT_PORCH = 10, VSYNC = 2,   VBACK_PORCH = 33, VTOTAL = 525;

    logic [10:0] hcount;
    logic [9:0]  vcount;
    logic endOfLine, endOfField, blank;

    // Horizontal & Vertical Counters
    always_ff @(posedge clk50) begin
        if (reset) hcount <= 0;
        else if (endOfLine) hcount <= 0;
        else hcount <= hcount + 11'd1;
    end
    assign endOfLine = (hcount == HTOTAL - 1);

    always_ff @(posedge clk50) begin
        if (reset) vcount <= 0;
        else if (endOfLine) begin
            if (endOfField) vcount <= 0;
            else vcount <= vcount + 10'd1;
        end
    end
    assign endOfField = (vcount == VTOTAL - 1);

    // Sync Pulses
    assign VGA_HS = !((hcount[10:7] == 4'b1010) & (hcount[6] | hcount[5]));
    assign VGA_VS = !(vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2);
    assign VGA_SYNC_n = 1'b1;

    // Coordinate mapping (divide 50MHz hcount by 2 for standard 25MHz VGA pixels)
    assign x = hcount >> 1;
    assign y = vcount[8:0];

    // Blanking logic
    assign blank = (hcount[10] & (hcount[9] | hcount[8])) | (vcount[9] | (vcount[8:5] == 4'b1111));
    
    always_ff @(posedge clk50) begin
        if (hcount[0]) VGA_BLANK_n <= ~blank; 
    end
    
    assign VGA_CLK = hcount[0]; 

endmodule