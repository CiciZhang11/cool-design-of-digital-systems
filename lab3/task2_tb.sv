// The testbench for task2.sv

`timescale 1ns/1ps

module task2_tb();

	// parameter
	// define module port connections
	logic CLOCK_50, CLOCK2_50;
	logic reset;
	logic [0:0] KEY;
	logic write_ready;
	logic [23:0] rom_data;


	// expected tracking
	int expected_addr;

	// instantiate module
	task2 #(.ROM_SIZE(48000)) uut (
		 .clk(CLOCK_50),
		 .reset(reset),
		 .write_ready(write_ready),
		 .rom_data(rom_data)
	);


	// create simulated clock
	initial begin
		 CLOCK_50 = 0;
		 forever #10 CLOCK_50 = ~CLOCK_50;
	end

	initial begin
		 CLOCK2_50 = 0;
		 forever #10 CLOCK2_50 = ~CLOCK2_50;
	end

	// define test inputs
	initial begin
		reset = 1; #100;	// reset
		reset = 0; #100;	// Release reset

		 expected_addr = 0;

		 // write_ready 
		 write_ready = 1; @(posedge CLOCK_50);

		 expected_addr = uut.rom_addr;
		 
		 
		 // test first 20 elements and print expected values
		 repeat (20) begin
			  @(posedge CLOCK_50);
			  force uut.write_ready = 1'b1; @(posedge CLOCK_50);
			  release uut.write_ready;

			  expected_addr = (expected_addr + 1) % 48000;
			  
			  #1;
			  $display("FIRST20: addr=%0d (exp=%0d) data=%h (exp=%h)",
					uut.rom_addr, expected_addr,
					uut.rom_data, uut.rom_data);
		 end
		 
		 // test last 20 elements and print expected values
		 force uut.rom_addr = 16'd47980; // move near end safely
		 #1;
		 release uut.rom_addr;    
		 expected_addr = 47980;

		 repeat (20) begin
			  @(posedge CLOCK_50);
			  force uut.write_ready = 1'b1; @(posedge CLOCK_50);
			  release uut.write_ready;

			  expected_addr = (expected_addr + 1) % 48000;
			  
			  #1;
			  $display("LAST20: addr=%0d (exp=%0d) data=%h (exp=%h)",
					uut.rom_addr, expected_addr,
					uut.rom_data, uut.rom_data);
		 end

		 // test wrap around behavior, test 10 elements
		 force uut.rom_addr = 16'd47999;
		 #1;
		 release uut.rom_addr; 
		 expected_addr = 47999;

		 repeat (10) begin
			  @(posedge CLOCK_50);
			  force uut.write_ready = 1'b1;
			  @(posedge CLOCK_50);
			  release uut.write_ready;

			  expected_addr = (expected_addr + 1) % 48000;
			  
			  #1;
			  $display("WRAP: addr=%0d (exp=%0d) data=%h (exp=%h)",
					uut.rom_addr, expected_addr,
					uut.rom_data, uut.rom_data);
		 end

		 $stop;
	end

endmodule // end task2_tb