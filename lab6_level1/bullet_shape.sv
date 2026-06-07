// bullet_shape.sv
// small line based star bullet
// base_x/base_y are the top-left corner
module bullet_shape(line_num, base_x, base_y, x0, y0, x1, y1);

    input  logic [3:0]  line_num;
    input  logic [10:0] base_x, base_y;
    output logic [10:0] x0, y0, x1, y1;

    always_comb begin
        case (line_num)
            // 5-line star outline, bounding box about 20 x 20
            4'd0: begin
                x0 = base_x + 11'd10;
                y0 = base_y + 11'd0;
                x1 = base_x + 11'd17;
                y1 = base_y + 11'd20;
            end // end case item

            4'd1: begin
                x0 = base_x + 11'd17;
                y0 = base_y + 11'd20;
                x1 = base_x + 11'd0;
                y1 = base_y + 11'd7;
            end // end case item

            4'd2: begin
                x0 = base_x + 11'd0;
                y0 = base_y + 11'd7;
                x1 = base_x + 11'd20;
                y1 = base_y + 11'd7;
            end // end case item

            4'd3: begin
                x0 = base_x + 11'd20;
                y0 = base_y + 11'd7;
                x1 = base_x + 11'd3;
                y1 = base_y + 11'd20;
            end // end case item

            4'd4: begin
                x0 = base_x + 11'd3;
                y0 = base_y + 11'd20;
                x1 = base_x + 11'd10;
                y1 = base_y + 11'd0;
            end // end case item

            default: begin
                x0 = 11'd0;
                y0 = 11'd0;
                x1 = 11'd0;
                y1 = 11'd0;
            end // end case item
        endcase // end case
    end // end always_comb

endmodule // end module bullet_shape
