/* This module updates the position and walking frame of the animated object.
 *
 * Inputs:
 *   clk       - 50 MHz clock
 *   reset     - reset position and frame
 *   update_en - update position and frame when high
 *
 * Outputs:
 *   base_x    - x offset of the object
 *   base_y    - y offset of the object
 *   frame_num - selects walking pose 0 or pose 1
 *
 */
module update_pos(clk, reset, update_en, base_x, base_y, frame_num);

	input logic clk, reset, update_en;
	output logic [10:0] base_x, base_y;
	output logic frame_num;
	
	/* The figure walks from left to right.
	 * When it reaches the right side, it starts again from the left.
	 * frame_num toggles each update to switch walking poses.
	 */
	localparam logic [10:0] START_X = 11'd10;
	localparam logic [10:0] START_Y = 11'd80;
	localparam logic [10:0] RIGHT_LIMIT = 11'd250;
	localparam logic [10:0] WALK_SPEED = 11'd4;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			base_x <= START_X;
			base_y <= START_Y;
			frame_num <= 1'b0;
		end else if (update_en) begin
			frame_num <= ~frame_num;
			
			if (base_x >= RIGHT_LIMIT) begin
				base_x <= START_X;
			end else begin
				base_x <= base_x + WALK_SPEED;
			end
		end
	end
	
endmodule