// This module selects the endpoints for each line of the animated object

module start_controller(line_num, base_x, base_y, x0, y0, x1, y1);

	input logic [3:0] line_num;
	input logic [10:0] base_x, base_y;
	output logic [10:0] x0, y0, x1, y1;
	

	always_comb begin
		case (line_num)
		
			// star edge 0: top to lower-right
			4'd0: begin
				x0 = base_x + 11'd60;
				y0 = base_y + 11'd0;
				x1 = base_x + 11'd95;
				y1 = base_y + 11'd105;
			end
			
			// star edge 1: lower-right to left-middle
			4'd1: begin
				x0 = base_x + 11'd95;
				y0 = base_y + 11'd105;
				x1 = base_x + 11'd5;
				y1 = base_y + 11'd40;
			end
			
			// star edge 2: left-middle to right-middle
			4'd2: begin
				x0 = base_x + 11'd5;
				y0 = base_y + 11'd40;
				x1 = base_x + 11'd115;
				y1 = base_y + 11'd40;
			end
			
			// star edge 3: right-middle to lower-left
			4'd3: begin
				x0 = base_x + 11'd115;
				y0 = base_y + 11'd40;
				x1 = base_x + 11'd25;
				y1 = base_y + 11'd105;
			end
			
			// star edge 4: lower-left to top
			4'd4: begin
				x0 = base_x + 11'd25;
				y0 = base_y + 11'd105;
				x1 = base_x + 11'd60;
				y1 = base_y + 11'd0;
			end
			
			// vertical center line
			4'd5: begin
				x0 = base_x + 11'd60;
				y0 = base_y + 11'd0;
				x1 = base_x + 11'd60;
				y1 = base_y + 11'd120;
			end
			
			// horizontal base line, drawn right-to-left
			4'd6: begin
				x0 = base_x + 11'd120;
				y0 = base_y + 11'd120;
				x1 = base_x + 11'd0;
				y1 = base_y + 11'd120;
			end
			
			// shallow positive slope
			4'd7: begin
				x0 = base_x + 11'd0;
				y0 = base_y + 11'd130;
				x1 = base_x + 11'd120;
				y1 = base_y + 11'd155;
			end
			
			// shallow negative slope
			4'd8: begin
				x0 = base_x + 11'd120;
				y0 = base_y + 11'd155;
				x1 = base_x + 11'd0;
				y1 = base_y + 11'd130;
			end
			
			// extra diagonal line for a more complete object
			4'd9: begin
				x0 = base_x + 11'd0;
				y0 = base_y + 11'd155;
				x1 = base_x + 11'd120;
				y1 = base_y + 11'd130;
			end
			
			default: begin
				x0 = 11'd0;
				y0 = 11'd0;
				x1 = 11'd0;
				y1 = 11'd0;
			end
		endcase
	end
	
endmodule