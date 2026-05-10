// Top level code of Task 2

module task2 (
	input logic CLOCK_50,     // clk
	input logic [9:0] SW,     // SW[7:0] = value A to search for
	input logic [3:0] KEY,    // KEY[0] = reset, KEY[3] = start

	output logic [9:0] LEDR,  // LEDR[9] = done, LEDR[0] = found
	output logic [6:0] HEX0,  // lower hex digit of Loc
	output logic [6:0] HEX1   // upper hex digit of Loc
);

	logic clk, reset, start_raw;
	logic start_sync_1, start_sync_2, start_prev, start;

	logic done, found;
	logic [4:0] result;

	logic init, update_mid, load_R, set_max, set_min;
	logic [4:0] address;
	logic [7:0] R;
	logic R_eq_A, R_gt_A, min_gt_max;

	assign clk = CLOCK_50;

	// KEY buttons are active-low
	assign reset = ~KEY[0];
	assign start_raw = ~KEY[3];

	// synchronize Start input to clock
	always_ff @(posedge clk) begin
		if (reset) begin
			start_sync_1 <= 0;
			start_sync_2 <= 0;
			start_prev   <= 0;
		end
		else begin
			start_sync_1 <= start_raw;
			start_sync_2 <= start_sync_1;
			start_prev   <= start_sync_2;
		end
	end

	// one-cycle start pulse
	assign start = start_sync_2 & ~start_prev;

	// controller
	controller u_ctrl (
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

	// datapath
	datapath u_dp (
		.clk(clk),
		.reset(reset),
		.init(init),
		.update_mid(update_mid),
		.load_R(load_R),
		.set_max(set_max),
		.set_min(set_min),
		.R(R),
		.A(SW[7:0]),
		.loc(address),
		.R_eq_A(R_eq_A),
		.R_gt_A(R_gt_A),
		.min_gt_max(min_gt_max)
	);

	// RAM
	ram32x8 u_ram (
		.clock   (clk),
		.address (address),
		.data    (8'd0),
		.wren    (1'b0),
		.q       (R)
	);

	assign result = found ? address : 5'd0;

	// Display Done and Found
	assign LEDR[9] = done;
	assign LEDR[0] = found;
	assign LEDR[8:1] = 8'd0;

	// Display Loc, if found, in hex on HEX1–HEX0
	seg7 h0 (
		.hex(found ? result[3:0] : 4'd0),
		.leds(HEX0)
	);

	seg7 h1 (
		.hex(found ? {3'b000, result[4]} : 4'd0),
		.leds(HEX1)
	);

endmodule // end module task 2