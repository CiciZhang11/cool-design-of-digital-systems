'timescale 1 ps / 1 ps
module task1_tb();
	logic clk;
	logic [4:0] address;
	logic [2:0] data;
	logic wren;
	logic [2:0] dout;
	
	task1 dut1 (
		.clk(clk),
		.address(address),
		.data(data),
		.wren(wren),
		.dout(dout)
	);
	task2 dut2 (
		.clk(clk),
		.address(address),
		.data(data),
		.wren(wren),
		.dout(dout)
	);
	parameter period = 100;
	initial begin
		clk <= 0;
		forever #(period/2) clk <= ~clk;
	end  // initial clk

	initial begin
		wren = 0; address = 5'd0; data = 3'd0; @(posedge clk); 
		wren = 1; address = 5'd5; data = 3'd5; @(posedge clk); // test writing 5 to address 5
		wren = 1; address = 5'd12; data = 3'd3; @(posedge clk); // test writing 3 to address 12
		wren = 0; address = 5'd5; data = 3'd0; @(posedge clk); // test reading address 5 (dout should be 5)
		wren = 0; address = 5'd12; data = 3'd0; @(posedge clk); // test reading address 12 (dout should be 3)
		wren = 0; address = 5'd0; data = 3'd0; @(posedge clk); // test reading address 0 (dout should be x or 0)
		wren = 0; address = 5'd0; data = 3'd0; repeat(5) @(posedge clk);
						
		$stop; // end simulation
	end  // end initial
endmodule // end task1_tb module
