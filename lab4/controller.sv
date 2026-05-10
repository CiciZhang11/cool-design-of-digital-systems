// CONTROLLER CODE of Task 1 

module controller(
	input logic clk, reset, start,
	input logic R_eq_A, R_gt_A, min_gt_max, // status signals
	output logic init, update_mid, load_R, set_max, set_min, done, found // controller signals
);
	typedef enum logic [2:0] {S_IDLE, S_UPDATE, S_WAIT, S_SEARCH, S_DONE} state_t;
	state_t ps, ns;

	// state register
	always_ff @(posedge clk) begin
		if (reset)
			ps <= S_IDLE;
		else
			ps <= ns;
	end // end always_ff

	// next state
	always_comb begin
		case(ps)
			S_IDLE: begin
				ns = start ? S_UPDATE : S_IDLE;
			end

			S_UPDATE: begin
				if (min_gt_max)
					ns = S_DONE;
				else
					ns = S_WAIT;
			end

			S_WAIT: begin
				ns = S_SEARCH;
			end

			S_SEARCH: begin
				if (R_eq_A)
					ns = S_DONE;
				else
					ns = S_UPDATE;
			end

			S_DONE: begin
				ns = start ? S_DONE : S_IDLE;
			end

			default: ns = S_IDLE;
		endcase
	end // end always_comb

	// outputs
	always_comb begin
		init = 0;
		update_mid = 0;
		load_R = 0;
		set_min = 0;
		set_max = 0;
		done = 0;
		found = 0;

		case(ps)
			S_IDLE: begin
				if (start)
					init = 1;
			end

			S_UPDATE: begin
				if (!min_gt_max)
					update_mid = 1;
			end

			S_WAIT: begin
				load_R = 1;
			end

			S_SEARCH: begin
				if (!R_eq_A) begin
					if (R_gt_A)
						set_max = 1;
					else
						set_min = 1;
				end
			end

			S_DONE: begin
				done = 1;
				found = R_eq_A;
			end
		endcase
	end // end always_comb
	
endmodule // end module task 2 controller