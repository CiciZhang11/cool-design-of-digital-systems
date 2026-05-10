// This is the testbench for task2 controller

`timescale 1 ps / 1 ps

module controller_tb();

	logic clk, reset, start;
	logic R_eq_A, R_gt_A, min_gt_max;

	logic init, update_mid, load_R, set_max, set_min, done, found;

	// Instantiate DUT
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

	// Clock
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end

	task print_outputs(input string label);
		begin
			$display("%s | init=%0b update_mid=%0b load_R=%0b set_max=%0b set_min=%0b done=%0b found=%0b",
					 label, init, update_mid, load_R, set_max, set_min, done, found);
		end
	endtask

	task reset_dut();
		begin
			reset = 1;
			start = 0;
			R_eq_A = 0;
			R_gt_A = 0;
			min_gt_max = 0;

			repeat(2) @(posedge clk); #1;
			reset = 0;
			@(posedge clk); #1;
		end
	endtask

	initial begin

		// Test 1: found case
		$display("\nTest 1: found case");

		reset_dut();

		start = 1;
		#1;
		print_outputs("S_IDLE with start=1, expect init=1");

		@(posedge clk); #1;
		start = 0;
		print_outputs("S_UPDATE, expect update_mid=1");

		@(posedge clk); #1;
		print_outputs("S_WAIT, expect load_R=1");

		R_eq_A = 1;
		R_gt_A = 0;
		min_gt_max = 0;

		@(posedge clk); #1;
		print_outputs("S_SEARCH, expect no set_min/set_max");

		@(posedge clk); #1;
		print_outputs("S_DONE, expect done=1 found=1");


		// Test 2: R > A, should set_max
		$display("\nTest 2: R > A, should set_max");

		reset_dut();

		start = 1;
		#1;
		print_outputs("S_IDLE with start=1, expect init=1");

		@(posedge clk); #1;
		start = 0;
		print_outputs("S_UPDATE, expect update_mid=1");

		@(posedge clk); #1;
		print_outputs("S_WAIT, expect load_R=1");

		R_eq_A = 0;
		R_gt_A = 1;
		min_gt_max = 0;

		@(posedge clk); #1;
		print_outputs("S_SEARCH, expect set_max=1 set_min=0");


		// Test 3: R < A, should set_min
		$display("\nTest 3: R < A, should set_min");

		reset_dut();

		start = 1;
		#1;
		print_outputs("S_IDLE with start=1, expect init=1");

		@(posedge clk); #1;
		start = 0;
		print_outputs("S_UPDATE, expect update_mid=1");

		@(posedge clk); #1;
		print_outputs("S_WAIT, expect load_R=1");

		R_eq_A = 0;
		R_gt_A = 0;
		min_gt_max = 0;

		@(posedge clk); #1;
		print_outputs("S_SEARCH, expect set_max=0 set_min=1");


		// Test 4: not found case, min_gt_max
		$display("\nTest 4: not found case, min_gt_max");

		reset_dut();

		start = 1;
		#1;
		print_outputs("S_IDLE with start=1, expect init=1");

		min_gt_max = 1;

		@(posedge clk); #1;
		start = 0;
		print_outputs("S_UPDATE with min_gt_max=1, expect update_mid=0");

		@(posedge clk); #1;
		print_outputs("S_DONE, expect done=1 found=0");


		// Test 5: no start, stay idle
		$display("\nTest 5: no start, stay idle");

		reset_dut();

		start = 0;
		R_eq_A = 0;
		R_gt_A = 0;
		min_gt_max = 0;

		#1;
		print_outputs("S_IDLE no start, expect all outputs 0");

		@(posedge clk); #1;
		print_outputs("Still S_IDLE, expect all outputs 0");

		$stop;
	end

endmodule