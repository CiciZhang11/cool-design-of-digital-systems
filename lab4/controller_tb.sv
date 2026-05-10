// this is the testbench for controller_tb.sv(task2)
//
// Testbench for the binary-search controller.
// We drive the status signals R_eq_A, R_gt_A, min_gt_max manually to
// pretend the datapath is running, and watch how the controller reacts.
//
//  1. first update to immediately exit to S_DONE, min_gt_max=1
//  2. Reset during S_WAIT
//  3. Reset during S_DONE
//  4. Normal binary search: found on first probe (R_eq_A=1 in S_SEARCH)
//  5. Normal binary search: R_gt_A path (set_max) then found
//  6. Normal binary search: R_lt_A path (set_min) then found
//  7. hold start

// TESTBENCH for controller_tb.sv

module controller_tb();

	logic clk, reset, start;
	logic R_eq_A, R_gt_A, min_gt_max;
	logic init, update_mid, load_R, set_max, set_min, done, found;

	controller dut (
		.clk(clk),
		.reset(reset),
		.start(start),
		.R_eq_A(R_eq_A),
		.R_gt_A(R_gt_A),
		.min_gt_max(min_gt_max),
		.init(init),
		.update_mid(update_mid),
		.load_R(load_R),
		.set_max(set_max),
		.set_min(set_min),
		.done(done),
		.found(found)
	);

	parameter period = 10;

	initial begin
		clk = 0;
		forever #(period/2) clk = ~clk;
	end

	initial begin
		reset = 1; start = 0;
		R_eq_A = 0; R_gt_A = 0; min_gt_max = 0;
		@(posedge clk); @(posedge clk);
		reset = 0; @(posedge clk); #1;

		// 1. Test min_gt_max, expected done = 1 and found = 0.
		min_gt_max = 1;
		start = 1; @(posedge clk); #1;
		start = 0; @(posedge clk); #1;
		@(posedge clk); #1;
		@(posedge clk); #1;

		// 2. Test reset during S_WAIT, expected FSM returns to S_IDLE.
		min_gt_max = 0; R_eq_A = 0; R_gt_A = 0;
		start = 1; @(posedge clk); #1;
		start = 0; @(posedge clk); #1;
		reset = 1; @(posedge clk); #1;
		reset = 0; @(posedge clk); #1;
		@(posedge clk); #1;

		// 3. Test reset during S_DONE, expected FSM returns to S_IDLE.
		min_gt_max = 0; R_eq_A = 0; R_gt_A = 0;
		start = 1; @(posedge clk); #1;
		start = 0; @(posedge clk); #1;
		@(posedge clk); #1;
		R_eq_A = 1; @(posedge clk); #1;
		reset = 1; @(posedge clk); #1;
		reset = 0; R_eq_A = 0; @(posedge clk); #1;
		@(posedge clk); #1;

		// 4. Test found on first probe, expected done = 1 and found = 1.
		min_gt_max = 0; R_eq_A = 0; R_gt_A = 0;
		start = 1; @(posedge clk); #1;
		start = 0; @(posedge clk); #1;
		@(posedge clk); #1;
		R_eq_A = 1; @(posedge clk); #1;
		@(posedge clk); #1;
		R_eq_A = 0; @(posedge clk); #1;

		// 5. Test R_gt_A path, expected set_max = 1, then found.
		min_gt_max = 0; R_eq_A = 0; R_gt_A = 0;
		start = 1; @(posedge clk); #1;
		start = 0; @(posedge clk); #1;
		@(posedge clk); #1;
		R_gt_A = 1; R_eq_A = 0; @(posedge clk); #1;
		R_gt_A = 0; @(posedge clk); #1;
		@(posedge clk); #1;
		R_eq_A = 1; @(posedge clk); #1;
		@(posedge clk); #1;
		R_eq_A = 0; @(posedge clk); #1;

		// 6. Test R_lt_A path, expected set_min = 1, then found.
		min_gt_max = 0; R_eq_A = 0; R_gt_A = 0;
		start = 1; @(posedge clk); #1;
		start = 0; @(posedge clk); #1;
		@(posedge clk); #1;
		R_gt_A = 0; R_eq_A = 0; @(posedge clk); #1;
		@(posedge clk); #1;
		@(posedge clk); #1;
		R_eq_A = 1; @(posedge clk); #1;
		@(posedge clk); #1;
		R_eq_A = 0; @(posedge clk); #1;

		// 7. Test hold start, expected FSM stays in S_DONE until start is released.
		min_gt_max = 0; R_eq_A = 0; R_gt_A = 0;
		start = 1; @(posedge clk); #1;
		@(posedge clk); #1;
		@(posedge clk); #1;
		R_eq_A = 1; @(posedge clk); #1;

		repeat(3) @(posedge clk);

		start = 0; R_eq_A = 0; @(posedge clk); #1;
		@(posedge clk); #1;

		$stop();
	end

endmodule // end controller_tb