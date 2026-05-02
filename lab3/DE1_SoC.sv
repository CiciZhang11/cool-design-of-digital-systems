/* Top-level module for LandsLand hardware connections to implement the parking lot system.*/

module DE1_SoC (
    input  logic CLOCK_50,
    input  logic CLOCK2_50,
    input  logic [0:0] KEY,
    input  logic [9:0] SW,
	 
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK,
	inout FPGA_I2C_SDAT,
	// Audio CODEC
	output AUD_XCK,
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
	input AUD_ADCDAT,
	output AUD_DACDAT
);

    // Signal definitions
    logic clk, reset;
    assign clk   = CLOCK_50;          
    assign reset = ~KEY[0]; 

    logic signed [23:0] audio_t1;
    logic signed [23:0] audio_t2;
    logic signed [23:0] audio_filtered;

    logic read_ready;
    logic write_ready;
    logic read;
    logic write;
 
    // Instantiate Audio CODEC Interface (part 1)
    part1 p1 (
		.CLOCK_50(CLOCK_50), .CLOCK2_50(CLOCK2_50), .KEY(KEY),
		.FPGA_I2C_SCLK(FPGA_I2C_SCLK), .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
		.AUD_XCK(AUD_XCK), .AUD_DACLRCK(AUD_DACLRCK), .AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_BCLK(AUD_BCLK), .AUD_ADCDAT(AUD_ADCDAT), .AUD_DACDAT(AUD_DACDAT)
    );
     
    // Instantiate Task 1
    task1 t1 (
        .readdata_left(readdata_left),
        .readdata_right(readdata_right),
        .audio_out(audio_t1)
    );

    // Instantiate Task 2
    task2 #(.ROM_SIZE(48000)) t2 (
        .clk(CLOCK_50),
        .reset(reset),
        .write_ready(write_ready),
        .rom_data(audio_t2)
    );
    
    // SW9 MUX
    logic [23:0] audio_in;
    assign audio_in = (SW[9] == 1'b0) ? audio_t1 : audio_t2;

    // Instantiate Task 3
	fir_filter #(.N(8), .ADDR_WIDTH(3), .LOG2_N(3)) t3 (
		 .clk(clk), .reset(reset),
		 .en(read_ready & write_ready),
		 .sample_in(audio_in),
		 .sample_out(audio_filtered)
	);

     
    // SW8 MUX
    logic [23:0] final_audio;
    assign final_audio = (SW[8] == 1'b1) ? audio_filtered : audio_in;

    // Connect to CODEC
    assign read  = read_ready & write_ready;
    assign write = read_ready & write_ready;

endmodule // end module DE1_SoC
