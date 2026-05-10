// DATAPATH CODE of Task 2

module datapath(
	input logic clk, reset,
	input logic init, update_mid, load_R, set_max, set_min, // controller signals
	input logic [7:0] R,
	input logic [7:0] A,
	output logic [4:0] loc,
	output logic R_eq_A, R_gt_A, min_gt_max // status signals
);
	logic signed [6:0] min, max;
	logic signed [6:0] mid_calc;
	logic [4:0] mid;
	logic [4:0] addr_reg;
	logic [7:0] A_reg;
	
	// combinational mid
	assign mid_calc = (min + max) >>> 1;
	assign mid = mid_calc[4:0];
	
	// RAM address output
	assign loc = addr_reg;
	
	// compare
	assign R_eq_A = (R == A_reg);
	assign R_gt_A = (R > A_reg);
	
	// search end condition
	assign min_gt_max = (min > max);
	
	// state update
	always_ff @(posedge clk) begin
		if (reset) begin
			min <= 0;
			max <= 31;
			addr_reg <= 0;
			A_reg <= 0;
		end
		else if (init) begin
			min <= 0;
			max <= 31;
			addr_reg <= 0;
			A_reg <= A;
		end
		else begin
			if (update_mid)
				addr_reg <= mid;
			if (set_max)
				max <= $signed({2'b00, mid}) - 7'sd1;
			if (set_min)
				min <= $signed({2'b00, mid}) + 7'sd1;
		end
	end
endmodule// end module datapath