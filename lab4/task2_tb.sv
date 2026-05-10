// TESTBENCH for TOP LEVEL module: task2

`timescale 1 ps / 1 ps

`timescale 1 ps / 1 ps

module task2_tb();

	logic CLOCK_50;
	logic [9:0] SW;
	logic [3:0] KEY;

	logic [9:0] LEDR;
	logic [6:0] HEX0;
	logic [6:0] HEX1;

	// Instantiate DUT
	task2 dut (
		.CLOCK_50(CLOCK_50),
		.SW(SW),
		.KEY(KEY),
		.LEDR(LEDR),
		.HEX0(HEX0),
		.HEX1(HEX1)
	);

	// Clock
	always begin
		CLOCK_50 = 0; #5;
		CLOCK_50 = 1; #5;
	end

	task reset_dut();
		begin
			KEY[0] = 0;     // press reset, active-low
			KEY[3] = 1;     // start not pressed
			repeat(3) @(posedge CLOCK_50); #1;

			KEY[0] = 1;     // release reset
			repeat(3) @(posedge CLOCK_50); #1;
		end
	endtask

	task press_start();
		begin
			KEY[3] = 0;     // press start, active-low
			@(posedge CLOCK_50); #1;

			KEY[3] = 1;     // release start
			@(posedge CLOCK_50); #1;
		end
	endtask

	task run_test(
		input logic [7:0] A,
		input logic expected_found
	);
		integer count;

		begin
			reset_dut();

			SW[7:0] = A;
			SW[9:8] = 2'b00;

			press_start();

			count = 0;

			while (!LEDR[9] && count < 100) begin
				@(posedge CLOCK_50); #1;
				count = count + 1;
			end

			$display(
				"A=%0d | Done=%0b Found=%0b HEX1=%7b HEX0=%7b || EXPECTED Found=%0b",
				A, LEDR[9], LEDR[0], HEX1, HEX0, expected_found
			);

			if (count >= 100)
				$display("FAIL: TIMEOUT\n");
			else if (LEDR[0] == expected_found)
				$display("PASS\n");
			else
				$display("FAIL\n");
		end
	endtask

	initial begin
		KEY = 4'b1111;
		SW = 10'd0;

		run_test(8'd0,   1'b1);
		run_test(8'd1,   1'b1);
		run_test(8'd5,   1'b1);
		run_test(8'd10,  1'b1);
		run_test(8'd15,  1'b1);
		run_test(8'd20,  1'b1);
		run_test(8'd31,  1'b1);

		run_test(8'd100, 1'b0);

		$stop;
	end

endmodule