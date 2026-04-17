'timescale 1 ps / 1 ps
module task1_tb();
	logic clock;
	logic [4:0] address;
	logic [2:0] data;
	logic wren;
	logic [2:0] q;
	
	task1 dut (
		.clock(clock),
		.address(address),
		.data(data),
		.wren(wren),
		.q(q)
	);
	parameter period = 100;
	initial begin
		clk <= 0;
		forever #(period/2) clk <= ~clk;
	end  // initial clock

	initial begin
		wren = 0; address = 5'd0; data = 3'd0; @(posedge clock); 
		wren = 1; address = 5'd5; data = 3'd5; @(posedge clock); // test writing 5 to address 5
		wren = 1; address = 5'd12; data = 3'd3; @(posedge clock); // test writing 3 to address 12
		wren = 0; address = 5'd5; data = 3'd0; @(posedge clock); // test reading address 5 (q should be 5)
		wren = 0; address = 5'd12; data = 3'd0; @(posedge clock); // test reading address 12 (q should be 3)
		wren = 0; address = 5'd0; data = 3'd0; @(posedge clock); // test reading address 0 (q should be x or 0)
		wren = 0; address = 5'd0; data = 3'd0; repeat(5) @(posedge clock);
						
		$stop; // end simulation
	end  // end initial
endmodule // end task1_tb module
