// DATAPATH CODE of Task 1
module datapath(
	input logic clk, reset,
	input logic init, set_max, set_min, // control signals
	input  logic [7:0] R,
	output logic [4:0] loc,
	output logic done, found
);
	logic [4:0] min, max, mid;
	logic R_eq_A;
	logic mid_eq_0;
	
	// Datapath logic (RTL operations)
	assign mid = (min + max) >> 1;
	always_ff @(posedge clk) begin
		if (reset) begin 
			min   <= 0;
			max   <= 31;
			loc   <= 0;
			found <= 0;
			done  <= 0;
		end 
		else begin 

			if (init) begin
				min   <= 0;
				max   <= 31;
				found <= 0;
				done  <= 0;
			end

			if (set_max)
				max <= mid - 1;

			if (set_min)
				min <= mid + 1;

			loc <= mid;

			if (R_eq_A)
				found <= 1;
				done <= 1;

			if (mid_eq_0)
				done <= 1;

		end
	end // end ff

endmodule // end datapath module