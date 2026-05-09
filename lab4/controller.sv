// CONTROLLER CODE of Task 1 

module controller(
	input logic clk, reset, start, 
	input logic [7:0] A, 
	input logic R_eq_A, R_gt_A, mid_eq_0, // status signals
	output logic init, set_max, set_min // control signals
); 

	// Define state names and variables 
	enum logic [1:0]{IDLE, SEARCH, DONE} ns, ps;

	// Controller logic w/ synchronous 
	always_ff @(posedge clk) begin
		if (reset) 
			ps <= IDLE;
		else 
			ps <= ns;
	end // end ff
	
	// Next-state logic 
	always_comb begin
		case(ps)
			IDLE: 
				ns = start ? SEARCH : IDLE;
			SEARCH:
				ns = (R_eq_A || mid_eq_0) ? DONE : SEARCH;
			DONE:
				ns = IDLE;
			default: ns = IDLE;
		endcase
	end // end comb
	
	// Output assignments
	always_comb begin
		init = 0;
		set_max = 0;
		set_min = 0;

		case(ps)
			IDLE: begin
				init = 1;
				set_max = 1;
				set_min = 1;
			end

			SEARCH: begin
				if (R_gt_A) 
					set_max = 1;
				else if (!R_eq_A)
					set_min = 1;
			end

			DONE: begin
				// no control signals
			end
		endcase
	end // end comb


endmodule // end module task 1 controller