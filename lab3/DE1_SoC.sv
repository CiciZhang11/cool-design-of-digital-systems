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
	assign clk = CLOCK_50;
    assign reset = ~KEY[0];

    logic [23:0] readdata_left, readdata_right;
    logic [23:0] final_output;
    logic read_ready, write_ready;

    logic [23:0] audio_t1;
    logic [23:0] audio_t2;
    logic [23:0] mux9_out;
    logic [23:0] audio_filtered;
    logic [23:0] final_audio;

    //  clock generator (REQUIRED for AUDIO CLOCK)
    clock_generator clk_gen (   
        .CLOCK2_50(CLOCK2_50),       
        .reset(reset),         
        .AUD_XCK(AUD_XCK)   
    ); 

    // CODEC
    audio_codec codec (
        .clk(CLOCK_50),
        .reset(reset),

        .read(read_ready),  
        .write(write_ready),  

        .writedata_left(final_audio),
        .writedata_right(final_audio),

        .AUD_ADCDAT(AUD_ADCDAT),

        .AUD_BCLK(AUD_BCLK),
        .AUD_ADCLRCK(AUD_ADCLRCK),
        .AUD_DACLRCK(AUD_DACLRCK),

        .read_ready(read_ready),
        .write_ready(write_ready),

        .readdata_left(readdata_left),
        .readdata_right(readdata_right),

        .AUD_DACDAT(AUD_DACDAT)
    );

     
    // Instantiate Task 1
    task1 t1 (
        .readdata_left(readdata_left),
        .readdata_right(readdata_right),
        .audio_out(audio_t1)
    );

    // Instantiate Task 2
    task2 t2 (
        .clk(CLOCK_50),
        .reset(reset),
        .write_ready(write_ready),
        .rom_data(audio_t2)
    );
    
    // SW9 MUX
    assign mux9_out = (SW[9] == 1'b0) ? audio_t1 : audio_t2;

    // Instantiate Task 3
    fir_filter #(
        .DATA_WIDTH(24),
        .N(8),
        .ADDR_WIDTH(3),
        .LOG2_N(3)      
    ) t3 (
        .clk(clk),
        .reset(reset),
        .en(write_ready),
        .sample_in(mux9_out),
        .sample_out(audio_filtered)
    );

    // SW8 MUX
	assign final_audio = (SW[8] == 1'b1) ? audio_filtered : mux9_out;

endmodule // end module DE1_SoC