// module car_counter Testbench
// First, test incr and decr while reset is asserted
// Then release reset and test decr when counter = 0
// Test different combinations of incr and decr
// Reset and test incr more than 18 times to ensure the counter does not exceed 18


module car_counter_tb();
	logic incr, decr, clk, reset;
	logic [4:0] counter; 
	car_counter dut(.*);
	
	// simulated clock
	parameter period = 100;
	initial begin
		clk <= 0;
		forever #(period/2) clk <= ~clk;
	end  // initial clock

	// test
	initial begin
		reset <= 1; incr = 1; decr = 0; @(posedge clk); 
						incr = 0; decr = 1; @(posedge clk);
						incr = 0; decr = 0; @(posedge clk); // test when no incr and no decr
		reset <= 0; incr = 0; decr = 0; @(posedge clk); 
						incr = 0; decr = 1; @(posedge clk); // test decr = 1 when counter = 0
						incr = 1; decr = 0; @(posedge clk);
						incr = 1; decr = 0; @(posedge clk);
						incr = 0; decr = 1; @(posedge clk);
		reset <= 1; incr = 0; decr = 0; @(posedge clk); 
		reset <= 0; incr = 0; decr = 0; @(posedge clk);
						incr = 1; decr = 0; repeat(23) @(posedge clk); // test incr 23 times
						
		$stop; // end simulation
	end  // initial
endmodule // end car_counter_tb module