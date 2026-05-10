// This is the testbench for DE1_SoC top level.
// Because we had already tested sufficient cases in task1 and task2 seperately,
// here, we just need to make sure switch 9 is correctly switching between task1
// and task2.
module DE1_SoC_tb();

    // Top level signals
    logic CLOCK_50;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic [9:0] LEDR;
    logic [6:0] HEX0;
    logic [6:0] HEX1;

    // Instantiate the top-level module
    DE1_SoC dut (.*);

    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end //initial

    initial begin
        // Initialize inputs
        KEY = 4'b1111;
        SW  = 10'b0; @(posedge CLOCK_50);
		  // 1. task1
        #1; SW[9] = 1'b0; 
        #1; SW[7:0] = 8'b10110110; 
        
        // Reset
        #1; KEY[0] = 0; 
        repeat(2) @(posedge CLOCK_50);
        #1; KEY[0] = 1;
        repeat(2) @(posedge CLOCK_50);

        // Press Start
        #1; KEY[3] = 0; 
        repeat(4) @(posedge CLOCK_50);
        #1; KEY[3] = 1;

        wait(LEDR[9] == 1'b1);
        
      
        repeat(5) @(posedge CLOCK_50);
		  // here, HEX1 should be 11111 in the waveform

		  // 2, task2
        #1; SW[9] = 1'b1;  
        #1; SW[7:0] = 8'b00000111; // a random number
        
        repeat(2) @(posedge CLOCK_50);

        // Reset the system
        #1; KEY[0] = 0; 
        repeat(2) @(posedge CLOCK_50);
        #1; KEY[0] = 1;
        repeat(2) @(posedge CLOCK_50);

        // Press Start
        #1; KEY[3] = 0; 
        repeat(4) @(posedge CLOCK_50);
        #1; KEY[3] = 1;

        // Wait for Task 2 to finish
        wait(LEDR[9] == 1'b1);
        
        //LEDR[0] should be up.
        repeat(5) @(posedge CLOCK_50);

        $stop();
    end //initial

endmodule //module