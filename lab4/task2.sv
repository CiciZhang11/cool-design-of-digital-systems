// Top level code of Task 2

module task2 (

	// Port definitions 
	input  logic clk, reset, start,
	input  logic [7:0] data_in,
	output logic done, found,
	output logic [4:0] result

);

	// Internal signals 
	
	// control signals
	logic init, set_max, set_min;

	// internal wires between modules 
	logic [4:0] address;
	logic [7:0] R;  

	logic R_eq_A, R_gt_A, mid_eq_0;

	// Instantiate controller 
	controller u_ctrl (
		.clk(clk),
		.reset(reset),
		.start(start),
		.A(data_in),
		.R_eq_A(R_eq_A),
		.R_gt_A(R_gt_A),
		.mid_eq_0(mid_eq_0),
		.init(init),
		.set_max(set_max),
		.set_min(set_min)
	);

	// Instantiate datapath 
	datapath u_dp (
		.clk(clk),
		.reset(reset),
		.init(init),
		.R_eq_A(R_eq_A),
		.R_gt_A(R_gt_A),
		.mid_eq_0(mid_eq_0),
		.set_max(set_max),
		.set_min(set_min),
		.R(R),
		.A(data_in),
		.loc(address),
		.done(done),
		.found(found)
	);

	// Instantiate RAM
	task2ram u_ram (
		.clk(clk),
		.address(address),
		.data(8'd0),
		.wren(1'b0),
		.dout(R)
	);

	// output assignment
	assign result = address;

endmodule // end module task 2