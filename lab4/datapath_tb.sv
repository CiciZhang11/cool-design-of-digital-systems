// This is the testbench for task2 datapath

`timescale 1 ps / 1 ps

module datapath_tb();

	logic clk, reset;

	logic init, update_mid, load_R, set_max, set_min;

	logic [7:0] R;
	logic [7:0] A;

	logic [4:0] loc;
	logic R_eq_A, R_gt_A, min_gt_max;

	// Instantiate DUT
	datapath dut (
		.clk(clk),
		.reset(reset),
		.init(init),
		.update_mid(update_mid),
		.load_R(load_R),
		.set_max(set_max),
		.set_min(set_min),
		.R(R),
		.A(A),
		.loc(loc),
		.R_eq_A(R_eq_A),
		.R_gt_A(R_gt_A),
		.min_gt_max(min_gt_max)
	);

	// Clock
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end

	task clear_controls();
		begin
			init = 0;
			update_mid = 0;
			load_R = 0;
			set_max = 0;
			set_min = 0;
		end
	endtask

	task reset_dut();
		begin
			reset = 1;
			clear_controls();
			A = 0;
			R = 0;

			repeat(2) @(posedge clk); #1;
			reset = 0;
			@(posedge clk); #1;
		end
	endtask

	task pulse_init(input logic [7:0] A_value);
		begin
			A = A_value;
			init = 1;
			@(posedge clk); #1;
			init = 0;
		end
	endtask

	task pulse_update_mid();
		begin
			update_mid = 1;
			@(posedge clk); #1;
			update_mid = 0;
		end
	endtask

	task pulse_load_R(input logic [7:0] R_value);
		begin
			R = R_value;
			load_R = 1;
			@(posedge clk); #1;
			load_R = 0;
		end
	endtask

	task pulse_set_max();
		begin
			set_max = 1;
			@(posedge clk); #1;
			set_max = 0;
		end
	endtask

	task pulse_set_min();
		begin
			set_min = 1;
			@(posedge clk); #1;
			set_min = 0;
		end
	endtask

	task check_outputs(
		input string label,
		input logic [4:0] exp_loc,
		input logic exp_R_eq_A,
		input logic exp_R_gt_A,
		input logic exp_min_gt_max
	);
		begin
			$display(
				"%s | loc=%0d R_eq_A=%0b R_gt_A=%0b min_gt_max=%0b || EXPECTED: loc=%0d R_eq_A=%0b R_gt_A=%0b min_gt_max=%0b",
				label,
				loc, R_eq_A, R_gt_A, min_gt_max,
				exp_loc, exp_R_eq_A, exp_R_gt_A, exp_min_gt_max
			);

			if ((loc == exp_loc) &&
				(R_eq_A == exp_R_eq_A) &&
				(R_gt_A == exp_R_gt_A) &&
				(min_gt_max == exp_min_gt_max))
				$display("PASS\n");
			else
				$display("FAIL\n");
		end
	endtask

	initial begin

		// Test 1: initialize and calculate first mid
		$display("\nTest 1: initialize and calculate first mid");

		reset_dut();

		pulse_init(8'd15);
		pulse_update_mid();

		check_outputs("After init and update_mid", 5'd15, 1'b0, 1'b0, 1'b0);


		// Test 2: equal compare
		$display("\nTest 2: equal compare");

		reset_dut();

		pulse_init(8'd15);
		pulse_update_mid();
		pulse_load_R(8'd15);

		check_outputs("A=15, R=15", 5'd15, 1'b1, 1'b0, 1'b0);


		// Test 3: R > A, set_max should move high down
		$display("\nTest 3: R > A, set_max should move high down");

		reset_dut();

		pulse_init(8'd10);
		pulse_update_mid();
		pulse_load_R(8'd15);

		check_outputs("Before set_max", 5'd15, 1'b0, 1'b1, 1'b0);

		pulse_set_max();
		pulse_update_mid();

		check_outputs("After set_max and update_mid", 5'd7, 1'b0, 1'b1, 1'b0);


		// Test 4: R < A, set_min should move low up
		$display("\nTest 4: R < A, set_min should move low up");

		reset_dut();

		pulse_init(8'd20);
		pulse_update_mid();
		pulse_load_R(8'd15);

		check_outputs("Before set_min", 5'd15, 1'b0, 1'b0, 1'b0);

		pulse_set_min();
		pulse_update_mid();

		check_outputs("After set_min and update_mid", 5'd23, 1'b0, 1'b0, 1'b0);


		// Test 5: not-found upper-bound case
		$display("\nTest 5: not-found upper-bound case");

		reset_dut();

		pulse_init(8'd100);

		pulse_update_mid();  // loc = 15
		pulse_load_R(8'd15);
		pulse_set_min();

		pulse_update_mid();  // loc = 23
		pulse_load_R(8'd23);
		pulse_set_min();

		pulse_update_mid();  // loc = 27
		pulse_load_R(8'd27);
		pulse_set_min();

		pulse_update_mid();  // loc = 29
		pulse_load_R(8'd29);
		pulse_set_min();

		pulse_update_mid();  // loc = 30
		pulse_load_R(8'd30);
		pulse_set_min();

		pulse_update_mid();  // loc = 31
		pulse_load_R(8'd31);
		pulse_set_min();

		check_outputs("After searching above max value", 5'd31, 1'b0, 1'b0, 1'b1);


		// Test 6: not-found lower-bound case
		$display("\nTest 6: not-found lower-bound case");

		reset_dut();

		pulse_init(8'd0);

		pulse_update_mid();  // loc = 15
		pulse_load_R(8'd15);
		pulse_set_max();

		pulse_update_mid();  // loc = 7
		pulse_load_R(8'd7);
		pulse_set_max();

		pulse_update_mid();  // loc = 3
		pulse_load_R(8'd3);
		pulse_set_max();

		pulse_update_mid();  // loc = 1
		pulse_load_R(8'd1);
		pulse_set_max();

		pulse_update_mid();  // loc = 0
		pulse_load_R(8'd1);
		pulse_set_max();

		check_outputs("After searching below min value", 5'd0, 1'b0, 1'b1, 1'b1);

		$stop;
	end

endmodule