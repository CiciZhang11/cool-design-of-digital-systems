module part2#(
	parameter ROM_SIZE = 48000,
	parameter ADDR_WIDTH = 16
) (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);
	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];
	
	logic [15:0] rom_addr;
	logic [23:0] rom_data;
	task2 audio_memory(
		.address(rom_addr),
		.clock(CLOCK_50),
		.q(rom_data)
	);
	assign writedata_left = rom_data;
	assign writedata_right = rom_data;
	assign write = write_ready;
	assign read = 1'b0;  // we don't read data from outside
	
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			rom_addr<= 16'd0;
		end //end if
		else if (write_ready) begin
			if(rom_addr == (ROM_SIZE-1)) begin
				rom_addr<=0;
			end //end inner if
			else begin
				rom_addr<= rom_addr+1;
			end //end inner else
		end //end outter else if
	end // end always_ff
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule
