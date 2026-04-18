// testbench for task3
`timescale 1 ps / 1 ps

module task3_tb();
	logic clk;
	logic wren;
	logic [4:0] addr_w;
	logic [4:0] addr_r;
	logic [2:0] data;
	logic [2:0] dout_r;

	task3 dut(.*);

	// simulated clock
	parameter period = 100;
	initial begin
		clk <= 0;
		forever #(period/2) clk <= ~clk;
	end // initial clock
	
	initial begin
		wren = 0; addr_w = 5'd0;  addr_r = 5'd0;  data = 3'd0; @(posedge clk);

		// Test boundary for 0 and 31
		wren = 1; addr_w = 5'd0;  addr_r = 5'd0;  data = 3'd5; @(posedge clk); // Write 5 to first address
		wren = 1; addr_w = 5'd31; addr_r = 5'd0;  data = 3'd2; @(posedge clk); // Write 2 to last address, read first
		wren = 0; addr_w = 5'd0;  addr_r = 5'd31; data = 3'd0; @(posedge clk); // Read last address
		
		// General read/write cases
		wren = 1; addr_w = 5'd1;  addr_r = 5'd0;  data = 3'd1; @(posedge clk); 
		wren = 0; addr_w = 5'd0;  addr_r = 5'd3;  data = 3'd0; @(posedge clk);
		
		// Simultaneous Read/Write: write 6 to addr 15 while reading addr 15
		wren = 1; addr_w = 5'd15; addr_r = 5'd15; data = 3'd6; @(posedge clk); 
		
		// Overwrite Existing Data
		wren = 1; addr_w = 5'd1;  addr_r = 5'd15; data = 3'd3; @(posedge clk); // Overwrite addr 1 with 3 (was 1), read 15
		wren = 0; addr_w = 5'd0;  addr_r = 5'd1;  data = 3'd0; @(posedge clk); // Read addr 1 to verify it is now 3
		
		wren = 0; addr_w = 5'd0;  addr_r = 5'd0;  data = 3'd0; repeat(5) @(posedge clk); 
						
		$stop;//end simulation
	end//initial
endmodule//end task3_tb module

