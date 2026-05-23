// This module selects the endpoints for each line of the walking figure

module walk_shape(line_num, frame_num, base_x, base_y, x0, y0, x1, y1);

	input logic [4:0] line_num;
	input logic frame_num;
	input logic [10:0] base_x, base_y;
	output logic [10:0] x0, y0, x1, y1;

	always_comb begin
		case (line_num)
		
			// head top
			5'd0: begin
				x0 = base_x + 11'd20;
				y0 = base_y + 11'd0;
				x1 = base_x + 11'd40;
				y1 = base_y + 11'd0;
			end
			
			// head right
			5'd1: begin
				x0 = base_x + 11'd40;
				y0 = base_y + 11'd0;
				x1 = base_x + 11'd40;
				y1 = base_y + 11'd20;
			end
			
			// head bottom
			5'd2: begin
				x0 = base_x + 11'd40;
				y0 = base_y + 11'd20;
				x1 = base_x + 11'd20;
				y1 = base_y + 11'd20;
			end
			
			// head left
			5'd3: begin
				x0 = base_x + 11'd20;
				y0 = base_y + 11'd20;
				x1 = base_x + 11'd20;
				y1 = base_y + 11'd0;
			end
			
			// body
			5'd4: begin
				x0 = base_x + 11'd30;
				y0 = base_y + 11'd20;
				x1 = base_x + 11'd30;
				y1 = base_y + 11'd60;
			end
			
			// shoulder line
			5'd5: begin
				x0 = base_x + 11'd15;
				y0 = base_y + 11'd32;
				x1 = base_x + 11'd45;
				y1 = base_y + 11'd32;
			end
			
			// hip line
			5'd6: begin
				x0 = base_x + 11'd20;
				y0 = base_y + 11'd60;
				x1 = base_x + 11'd40;
				y1 = base_y + 11'd60;
			end
			
			// left arm
			5'd7: begin
				if (frame_num == 1'b0) begin
					x0 = base_x + 11'd30;
					y0 = base_y + 11'd32;
					x1 = base_x + 11'd8;
					y1 = base_y + 11'd48;
				end else begin
					x0 = base_x + 11'd30;
					y0 = base_y + 11'd32;
					x1 = base_x + 11'd12;
					y1 = base_y + 11'd20;
				end
			end
			
			// right arm
			5'd8: begin
				if (frame_num == 1'b0) begin
					x0 = base_x + 11'd30;
					y0 = base_y + 11'd32;
					x1 = base_x + 11'd48;
					y1 = base_y + 11'd20;
				end else begin
					x0 = base_x + 11'd30;
					y0 = base_y + 11'd32;
					x1 = base_x + 11'd52;
					y1 = base_y + 11'd48;
				end
			end
			
			// left leg
			5'd9: begin
				if (frame_num == 1'b0) begin
					x0 = base_x + 11'd30;
					y0 = base_y + 11'd60;
					x1 = base_x + 11'd12;
					y1 = base_y + 11'd95;
				end else begin
					x0 = base_x + 11'd30;
					y0 = base_y + 11'd60;
					x1 = base_x + 11'd25;
					y1 = base_y + 11'd95;
				end
			end
			
			// right leg
			5'd10: begin
				if (frame_num == 1'b0) begin
					x0 = base_x + 11'd30;
					y0 = base_y + 11'd60;
					x1 = base_x + 11'd35;
					y1 = base_y + 11'd95;
				end else begin
					x0 = base_x + 11'd30;
					y0 = base_y + 11'd60;
					x1 = base_x + 11'd50;
					y1 = base_y + 11'd95;
				end
			end
			
			// ground line / walking direction reference
			5'd11: begin
				x0 = base_x + 11'd0;
				y0 = base_y + 11'd100;
				x1 = base_x + 11'd60;
				y1 = base_y + 11'd100;
			end
			
			default: begin
				x0 = 11'd0;
				y0 = 11'd0;
				x1 = 11'd0;
				y1 = 11'd0;
			end
		endcase // end case (line_num)
	end // end always_comb
	
endmodule // END WALK_SHAPE