// This module selects the endpoints for each line of a left-facing cannon
module cannon_shape(
    input  logic [3:0]  line_num,
    input  logic [10:0] base_x, base_y,
    output logic [10:0] x0, y0, x1, y1
);

    always_comb begin
        case (line_num)
            // ==========================================
            // CANNON BARREL (Angled up and facing left)
            // ==========================================
            
            // Barrel Top Edge
            4'd0: begin
                x0 = base_x + 11'd10;  y0 = base_y + 11'd25; // Muzzle top
                x1 = base_x + 11'd35;  y1 = base_y + 11'd45; // Breech top
            end
            
            // Barrel Bottom Edge
            4'd1: begin
                x0 = base_x + 11'd10;  y0 = base_y + 11'd25; // Muzzle bottom
                x1 = base_x + 11'd35;  y1 = base_y + 11'd45; // Breech bottom
            end
            
            // Barrel Muzzle (Front Opening on Left)
            4'd2: begin
                x0 = base_x + 11'd10;  y0 = base_y + 11'd25;
                x1 = base_x + 11'd10;  y1 = base_y + 11'd35;
            end
            
            // Barrel Breech (Back Round/Flat Wall on Right)
            4'd3: begin
                x0 = base_x + 11'd35;  y0 = base_y + 11'd25;
                x1 = base_x + 11'd35;  y1 = base_y + 11'd45;
            end
            
            

            // ==========================================
            // WHEEL (Octagon / Diamond Structure)
            // ==========================================
            
            // Wheel Top to Right
            4'd4: begin
                x0 = base_x + 11'd40;  y0 = base_y + 11'd60; // Wheel Top
                x1 = base_x + 11'd55;  y1 = base_y + 11'd75; // Wheel Right
            end
            
            // Wheel Right to Bottom
            4'd5: begin
                x0 = base_x + 11'd55;  y1 = base_y + 11'd75;
                x1 = base_x + 11'd40;  y1 = base_y + 11'd90; // Wheel Bottom
            end
            
            // Wheel Bottom to Left
            4'd6: begin
                x0 = base_x + 11'd40;  y0 = base_y + 11'd90;
                x1 = base_x + 11'd25;  y1 = base_y + 11'd75; // Wheel Left
            end
            
            // Wheel Left to Top
            4'd7: begin
                x0 = base_x + 11'd25;  y0 = base_y + 11'd75;
                x1 = base_x + 11'd40;  y1 = base_y + 11'd60;
            end

            // ==========================================
            // MOUNT / TRAIL (Connects barrel to wheel/ground)
            // ==========================================
            4'd8: begin
                x0 = base_x + 11'd48;  y0 = base_y + 11'd48; // Underneath barrel
                x1 = base_x + 11'd40;  y1 = base_y + 11'd75; // Wheel center axle
            end

            default: begin
                x0 = 11'd0; y0 = 11'd0;
                x1 = 11'd0; y1 = 11'd0;
            end
        endcase
    end
endmodule