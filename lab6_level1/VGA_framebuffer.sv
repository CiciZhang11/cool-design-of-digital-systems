/*
 * Black-and-white VGA Framebuffer
 * 640 X 480 VGA timing for a 50 MHz clock: one pixel every other cycle
 * 
 * HCOUNT 1599 0             1279       1599 0
 *            _______________              ________
 * __________|    Video      |____________|  Video
 * 
 * 
 * |SYNC| BP |<-- HACTIVE -->|FP|SYNC| BP |<-- HACTIVE
 *       _______________________      _____________
 * |____|       VGA_HS          |____|
 *
 * Inputs:
 *   clk50          - should be connected to a 50 MHz clock
 *   reset          - resets the module
 *   x              - x coordinate of the pixel
 *   y              - y coordinate of the pixel
 *   pixel_color    - color of the pixel, black or white
 *   pixel_write    - write to the pixel or not
 *
 * Outputs:
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 		    - Blue data of the VGA connection
 *   VGA_CLK        - VGA's clock signal
 *   VGA_HS         - Horizontal Sync of the VGA connection
 *   VGA_VS         - Vertical Sync of the VGA connection
 *   VGA_BLANK_n    - Blanking interval of the VGA connection
 *   VGA_SYNC_n     - Enable signal for the sync of the VGA connection
 */
/*
 * 3-bit color VGA Framebuffer
 * 640 x 480 VGA timing for a 50 MHz clock
 * one pixel every other cycle
 */

module VGA_framebuffer(clk50, reset, x, y, pixel_color, pixel_write, 
    VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);
    
    parameter   HACTIVE      = 11'd1280,
                HFRONT_PORCH = 11'd32,
                HSYNC        = 11'd192,
                HBACK_PORCH  = 11'd96,   
                HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC + HBACK_PORCH;

    parameter   VACTIVE      = 10'd480,
                VFRONT_PORCH = 10'd10,
                VSYNC        = 10'd2,
                VBACK_PORCH  = 10'd33,
                VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC + VBACK_PORCH;
    
    input  logic        clk50, reset;
    input  logic [10:0] x, y;
    input  logic [2:0]  pixel_color;
    input  logic        pixel_write;

    output logic [7:0] VGA_R, VGA_G, VGA_B;
    output logic       VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n;

    logic [10:0] hcount;
    logic        endOfLine;
    logic [9:0]  vcount;
    logic        endOfField;
    logic        blank;

    // 3-bit color framebuffer
    logic [2:0] framebuffer [307199:0];

    logic [18:0] read_address;
    logic [18:0] write_address;
    logic [2:0]  pixel_read;

    always_ff @(posedge clk50 or posedge reset) begin
        if (reset) begin
            hcount <= 11'd0;
        end
        else if (endOfLine) begin
            hcount <= 11'd0;
        end
        else begin
            hcount <= hcount + 11'd1;
        end
    end  // hcount

    assign endOfLine = hcount == HTOTAL - 1;

    always_ff @(posedge clk50 or posedge reset) begin
        if (reset) begin
            vcount <= 10'd0;
        end
        else if (endOfLine) begin
            if (endOfField) begin
                vcount <= 10'd0;
            end
            else begin
                vcount <= vcount + 10'd1;
            end
        end
    end  // vcount

    assign endOfField = vcount == VTOTAL - 1;

    assign VGA_HS = !( (hcount[10:7] == 4'b1010) & (hcount[6] | hcount[5]) );
    assign VGA_VS = !( vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2 );
    assign VGA_SYNC_n = 1'b1;

    assign blank = ( hcount[10] & (hcount[9] | hcount[8]) ) |
                   ( vcount[9] | (vcount[8:5] == 4'b1111) );

    assign write_address = x + (y << 9) + (y << 7);
    assign read_address  = (hcount >> 1) + (vcount << 9) + (vcount << 7);

    always_ff @(posedge clk50) begin
        if (pixel_write) begin
            framebuffer[write_address] <= pixel_color;
        end

        if (hcount[0]) begin
            pixel_read  <= framebuffer[read_address];
            VGA_BLANK_n <= ~blank;
        end
    end  // framebuffer read and write

    assign VGA_CLK = hcount[0];

    always_comb begin
        case (pixel_read)
            3'b000: begin
                VGA_R = 8'h00;
                VGA_G = 8'h00;
                VGA_B = 8'h00;
            end

            3'b001: begin
                VGA_R = 8'h00;
                VGA_G = 8'h00;
                VGA_B = 8'hFF;
            end

            3'b010: begin
                VGA_R = 8'h00;
                VGA_G = 8'hFF;
                VGA_B = 8'h00;
            end

            3'b011: begin
                VGA_R = 8'h00;
                VGA_G = 8'hFF;
                VGA_B = 8'hFF;
            end

            3'b100: begin
                VGA_R = 8'hFF;
                VGA_G = 8'h00;
                VGA_B = 8'h00;
            end

            3'b101: begin
                VGA_R = 8'hFF;
                VGA_G = 8'h00;
                VGA_B = 8'hFF;
            end

            3'b110: begin
                VGA_R = 8'hFF;
                VGA_G = 8'hA0;
                VGA_B = 8'h00;
            end

            3'b111: begin
                VGA_R = 8'hFF;
                VGA_G = 8'hFF;
                VGA_B = 8'hFF;
            end

            default: begin
                VGA_R = 8'h00;
                VGA_G = 8'h00;
                VGA_B = 8'h00;
            end
        endcase
    end  // RGB decode

endmodule  // VGA_framebuffer
