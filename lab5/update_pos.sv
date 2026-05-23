// This module is used to update the position

module update_pos(clk, reset, update_en, base_x, base_y, frame_num);

	input logic clk, reset, update_en;
	output logic [10:0] base_x, base_y;
	output logic frame_num;
	
	localparam logic [10:0] START_X     = 11'd10;
	localparam logic [10:0] START_Y     = 11'd10;
	localparam logic [10:0] LEFT_LIMIT  = 11'd10;
	localparam logic [10:0] RIGHT_LIMIT = 11'd500;
	localparam logic [10:0] BOTTOM_LIMIT = 11'd260;
	localparam logic [10:0] X_SPEED     = 11'd8;
	localparam logic [10:0] Y_SPEED     = 11'd2;
	
	logic move_right;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			base_x <= START_X;
			base_y <= START_Y;
			frame_num <= 1'b0;
			move_right <= 1'b1;
		end else if (update_en) begin
		
			// switch object pose each frame
			frame_num <= ~frame_num;
			
			// horizontal bouncing motion
			if (move_right) begin
				if (base_x >= RIGHT_LIMIT) begin
					move_right <= 1'b0;
					base_x <= base_x - X_SPEED;
				end else begin
					base_x <= base_x + X_SPEED;
				end
			end else begin
				if (base_x <= LEFT_LIMIT) begin
					move_right <= 1'b1;
					base_x <= base_x + X_SPEED;
				end else begin
					base_x <= base_x - X_SPEED;
				end
			end // end if (move_right) begin
			
			// slow downward motion
			if (base_y >= BOTTOM_LIMIT) begin
				base_y <= START_Y;
			end else begin
				base_y <= base_y + Y_SPEED;
			end
		end // end if
	end // end always_ff
	
endmodule // END MODULE update_pos