// This is a module for drawing a big scary human
module big_human_shape(
    input  logic [4:0] line_num,
    output logic [10:0] x0, y0, x1, y1
);
    // Center of screen is roughly 320x240
    localparam logic [10:0] BX = 11'd300; 
    localparam logic [10:0] BY = 11'd100;
    localparam logic [10:0] SX = 11'd150;
    localparam logic [10:0] SY = 11'd125;

    always_comb begin
        case (line_num)
            // head+body
            5'd0:  begin x0=BX+40;  y0=BY+0;   x1=BX+80;  y1=BY+0;   end // head top
            5'd1:  begin x0=BX+80;  y0=BY+0;   x1=BX+80;  y1=BY+40;  end // head right
            5'd2:  begin x0=BX+80;  y0=BY+40;  x1=BX+40;  y1=BY+40;  end // head bottom
            5'd3:  begin x0=BX+40;  y0=BY+40;  x1=BX+40;  y1=BY+0;   end // head left
            5'd4:  begin x0=BX+60;  y0=BY+40;  x1=BX+60;  y1=BY+120; end // body
            
            // arms
            5'd5:  begin x0=BX+60;  y0=BY+64;  x1=BX+16;  y1=BY+96;  end // left arm
            5'd6:  begin x0=BX+60;  y0=BY+64;  x1=BX+104; y1=BY+96;  end // right arm
            5'd7:  begin x0=BX+60;  y0=BY+120; x1=BX+24;  y1=BY+190; end // left leg
            5'd8: begin x0=BX+60;  y0=BY+120; x1=BX+96;  y1=BY+190; end // right leg
            
            // scary face
            5'd9: begin x0=BX+50;  y0=BY+12;  x1=BX+55;  y1=BY+12;  end // left eye
            5'd10: begin x0=BX+65;  y0=BY+12;  x1=BX+70;  y1=BY+12;  end // right eye
            5'd11: begin x0=BX+52;  y0=BY+28;  x1=BX+68;  y1=BY+28;  end // mouth
            

        // Draw the start
            // star edge 0: top to lower-right
            5'd12: begin
                x0 = SX + 11'd60;
                y0 = SY + 11'd0;
                x1 = SX + 11'd95;
                y1 = SY + 11'd105;
            end

            // star edge 1: lower-right to left-middle
            5'd13: begin
                x0 = SX + 11'd95;
                y0 = SY + 11'd105;
                x1 = SX + 11'd5;
                y1 = SY + 11'd40;
            end

            // star edge 2: left-middle to right-middle
            5'd14: begin
                x0 = SX + 11'd5;
                y0 = SY + 11'd40;
                x1 = SX + 11'd115;
                y1 = SY + 11'd40;
            end

            // star edge 3: right-middle to lower-left
            5'd15: begin
                x0 = SX + 11'd115;
                y0 = SY + 11'd40;
                x1 = SX + 11'd25;
                y1 = SY + 11'd105;
            end

            // star edge 4: lower-left to top
            5'd16: begin
                x0 = SX + 11'd25;
                y0 = SY + 11'd105;
                x1 = SX + 11'd60;
                y1 = SY + 11'd0;
            end

            // vertical center line
            5'd17: begin
                x0 = SX + 11'd60;
                y0 = SY + 11'd0;
                x1 = SX + 11'd60;
                y1 = SY + 11'd120;
            end

            // horizontal base line, drawn right-to-left
            5'd18: begin
                x0 = SX + 11'd120;
                y0 = SY + 11'd120;
                x1 = SX + 11'd0;
                y1 = SY + 11'd120;
            end

            // shallow positive slope
            5'd19: begin
                x0 = SX + 11'd0;
                y0 = SY + 11'd130;
                x1 = SX + 11'd120;
                y1 = SY + 11'd155;
            end

            // shallow negative slope
            5'd20: begin
                x0 = SX + 11'd120;
                y0 = SY + 11'd155;
                x1 = SX + 11'd0;
                y1 = SY + 11'd130;
            end

            // extra diagonal line
            5'd21: begin
                x0 = SX + 11'd0;
                y0 = SY + 11'd155;
                x1 = SX + 11'd120;
                y1 = SY + 11'd130;
            end

            default: begin
                x0 = 11'd0;
                y0 = 11'd0;
                x1 = 11'd0;
                y1 = 11'd0;
            end
        endcase
    end
endmodule // END BIG_HUMAN_SHAPE
