// DATAPATH CODE of Task 1
module datapath(
	input logic clk, reset,
	output logic R_eq_A, R_gt_A, mid_eq_0,
	input logic init, set_max, set_min, // control signals
	input logic [7:0] R,
	input logic [7:0] A,

	output logic [4:0] loc,
	output logic done, found
);

	logic [4:0] min, max, mid;
	logic [7:0] R_reg;

	// combinational midpoint
	assign mid = (min + max) >> 1;

	// comparison signals
	always_ff @(posedge clk) begin
		R_reg <= R;
	end

	assign R_eq_A = (R_reg == A);
	assign R_gt_A = (R_reg > A);

	assign mid_eq_0 = (min > max);

	// Datapath logic (RTL operations)
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

			if (R_eq_A) begin 
				found <= 1;
				done  <= 1;
			end

			if (mid_eq_0)
				done <= 1;

		end
	end

endmodule // end datapath module