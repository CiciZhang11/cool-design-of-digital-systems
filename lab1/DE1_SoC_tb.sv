/* testbench for the DE1_SoC */
  // First, assert reset and verify that the system starts at 0.
  // Test: changes in outer and inner should not affect the count
  
  // Then, release reset and test invalid sensor sequences do not affect the count
  // Reset again
  
  
  // Next, test valid entry and exit sequences
  // Finally, test one exit sequences to ensure that the count does not go below 0
  
  // And test 20 entry sequences to ensure that the count does not exceed 18.
  
module DE1_SoC_tb();

  // define signals
  logic       CLOCK_50;
  logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  logic [9:0] LEDR;
  wire  [35:0] V_GPIO;           
  logic [35:0] V_GPIO_in;        
  logic [35:0] V_GPIO_dir;      
  
  // define parameters
  parameter T = 20;
  
  // instantiate module
  DE1_SoC dut (.*);
  
  // define simulated clock
  initial begin
    CLOCK_50 <= 0;
    forever  #(T/2)  CLOCK_50 <= ~CLOCK_50;
  end  // initial clock
  
	// tristate buffers for V_GPIO
	genvar i;                                   
	generate                                     
		for (i = 0; i < 36; i++) begin : gpio    
		assign V_GPIO[i] = V_GPIO_dir[i] ? V_GPIO_in[i] : 1'bZ; 
		end
	endgenerate  

	initial begin
		V_GPIO_in  = '0;  
		V_GPIO_dir = '0;   
		
		V_GPIO_dir[0] = 1'b1;   // outer input 
		V_GPIO_dir[1] = 1'b1;   // inner input 
		V_GPIO_dir[2] = 1'b1;   // reset input 
		V_GPIO_dir[3] = 1'b0;   // outer LED output 
		V_GPIO_dir[4] = 1'b0;   // inner LED output

		// First, assert reset and verify that the system starts at 0.
		// Test: changes in enter and exit should not affect the count
		V_GPIO_in[2] = 1; V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50); 
								V_GPIO_in[0] = 1; V_GPIO_in[1] = 0; @(posedge CLOCK_50);
								V_GPIO_in[0] = 1; V_GPIO_in[1] = 1; @(posedge CLOCK_50);
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 1; @(posedge CLOCK_50);
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50); // enter
								
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 1; @(posedge CLOCK_50);
								V_GPIO_in[0] = 1; V_GPIO_in[1] = 1; @(posedge CLOCK_50); 
								V_GPIO_in[0] = 1; V_GPIO_in[1] = 0; @(posedge CLOCK_50); 
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);  
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50); // exit
								
								

		// Then, release reset and test invalid sensor sequences do not affect the count
		V_GPIO_in[2] = 0; V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);

								V_GPIO_in[0] = 1; V_GPIO_in[1] = 0; @(posedge CLOCK_50);    // 00 -> 10
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);    // 10 -> 00

								V_GPIO_in[0] = 0; V_GPIO_in[1] = 1; @(posedge CLOCK_50);    // 00 -> 01
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);    // 01 -> 00

								V_GPIO_in[0] = 1; V_GPIO_in[1] = 1; @(posedge CLOCK_50);    // 00 -> 11
								V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);    // 11 -> 00

		// Reset again
		V_GPIO_in[2] = 1; V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50); 
		V_GPIO_in[2] = 0; @(posedge CLOCK_50); 

		// Next, test valid entry sequence: 00 -> 10 -> 11 -> 01 -> 00
                     V_GPIO_in[0] = 1; V_GPIO_in[1] = 0; @(posedge CLOCK_50);  
                     V_GPIO_in[0] = 1; V_GPIO_in[1] = 1; @(posedge CLOCK_50);  
                     V_GPIO_in[0] = 0; V_GPIO_in[1] = 1; @(posedge CLOCK_50);  
                     V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);    // count +1
							V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);

		// Test valid exit sequence: 00 -> 01 -> 11 -> 10 -> 00
                     V_GPIO_in[0] = 0; V_GPIO_in[1] = 1; @(posedge CLOCK_50);
                     V_GPIO_in[0] = 1; V_GPIO_in[1] = 1; @(posedge CLOCK_50); 
                     V_GPIO_in[0] = 1; V_GPIO_in[1] = 0; @(posedge CLOCK_50); 
                     V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);    // count -1
							V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);

		// Test one exit sequence to ensure that the count does not go below 0
                     V_GPIO_in[0] = 0; V_GPIO_in[1] = 1; @(posedge CLOCK_50);  
                     V_GPIO_in[0] = 1; V_GPIO_in[1] = 1; @(posedge CLOCK_50);   
                     V_GPIO_in[0] = 1; V_GPIO_in[1] = 0; @(posedge CLOCK_50); 
                     V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);    // should stay 0
							V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);

		// Reset again
		V_GPIO_in[2] = 1; V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50); 
		V_GPIO_in[2] = 0; @(posedge CLOCK_50); 
		
		// test 20 entry sequences to ensure that the count does not exceed 18.
		repeat (20) begin   
                     V_GPIO_in[0] = 1; V_GPIO_in[1] = 0; @(posedge CLOCK_50);
                     V_GPIO_in[0] = 1; V_GPIO_in[1] = 1; @(posedge CLOCK_50);
                     V_GPIO_in[0] = 0; V_GPIO_in[1] = 1; @(posedge CLOCK_50);
                     V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);
							V_GPIO_in[0] = 0; V_GPIO_in[1] = 0; @(posedge CLOCK_50);
		end

		@(posedge CLOCK_50);
		$stop;
  end

endmodule  // DE1_SoC_tb
