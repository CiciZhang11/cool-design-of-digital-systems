// this is the testbench for task1, top module. 
// The idea of this testbench is to test regular cases that has been tested in datapath
// plus 2 edge cases: reset in the middle and constant start. 
module task1_tb();
    
    // Top level ports
    logic [7:0] SW;
    logic [3:0] KEY;
    logic CLOCK_50;
    logic [6:0] HEX0;
    logic [9:0] LEDR;
    
    // Instantiate the top level using SystemVerilog implicit port connections
    task1 dut (.*);
    
    // 50 MHz Clock generation (20ns period)
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end
    
    initial begin
        // Initialize board state: Keys unpressed (active-low means 1 is off), Switches at 0
        KEY = 4'b1111; 
        SW = 8'b00000000; 
        
        @(posedge CLOCK_50);
        

        #1; KEY[0] = 0; // Active-low reset
        repeat(2) @(posedge CLOCK_50);
        #1; KEY[0] = 1;
        repeat(2) @(posedge CLOCK_50);

		  // 1. SW = 8'b10110110, expect 5
        #1; SW = 8'b10110110; 
        
        // Press Start
        #1; KEY[3] = 0; 
        repeat(4) @(posedge CLOCK_50); // wait for user_input
        #1; KEY[3] = 1;
        
        // Wait for the done flag to light up
        wait(LEDR[9] == 1'b1);
        
        // Wait a few cycles to observe the final HEX0 value
        repeat(3) @(posedge CLOCK_50);

		  // 2. SW = 8'b11111111, expect 8
        #1; SW = 8'b11111111;
        
        #1; KEY[3] = 0; 
        repeat(4) @(posedge CLOCK_50);
        #1; KEY[3] = 1;
        
        wait(LEDR[9] == 1'b1);
        repeat(3) @(posedge CLOCK_50);


		  //3. reset in the middle
        #1; SW = 8'b11111111;
        
        // Press Start
        #1; KEY[3] = 0; 
        repeat(2) @(posedge CLOCK_50);
        #1; KEY[3] = 1;
        //regular shifting for a bit
        repeat(3) @(posedge CLOCK_50);
        
        // Hit Reset while it's calculating
        #1; KEY[0] = 0; 
        repeat(2) @(posedge CLOCK_50);
        #1; KEY[0] = 1;
        
        // stays idle, and result=0, LEDR[9] stays off
        repeat(5) @(posedge CLOCK_50);


        // 4. constant start
        #1; SW = 8'b00001111; // Expect 4
        
        // Press and hold Start indefinitely
        #1; KEY[3] = 0; 
        
        wait(LEDR[9] == 1'b1);
        
        repeat(10) @(posedge CLOCK_50);
        
        // Finally release the button
        #1; KEY[3] = 1;
        repeat(3) @(posedge CLOCK_50);

		  // 5. all 0, early exit
        #1; SW = 8'b00000000;
        
        // Press Start
        #1; KEY[3] = 0; 
        repeat(4) @(posedge CLOCK_50);
        #1; KEY[3] = 1;
        wait(LEDR[9] == 1'b1);
        repeat(3) @(posedge CLOCK_50);

        $stop();
    end
endmodule