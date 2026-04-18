/* testbench for the DE1_SoC */

// This testbench first verifies Task 2 operation
// then tests switching from Task 2 to Task 3
// and finally test Task 3 


`timescale 1 ps / 1 ps

module DE1_SoC_tb();

    logic       CLOCK_50;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;

    parameter T = 20;

    // instantiate module
    DE1_SoC #(.MAX_COUNT(26'd1)) dut (.*); 

    // define simulated clock
    initial begin
        CLOCK_50 = 0;
        forever #(T/2) CLOCK_50 = ~CLOCK_50;
    end  // initial clock

    initial begin
        // initialize inputs: SW and KEY
        SW  = 10'd0; KEY = 4'b1111;
		  
		  // First SW9 is off testing task 2
		  SW[9]   = 0; 
		  
		  // Task2 Input: wren = SW[0], data = SW[3:1], address = SW[8:4]
		  // - Write "1" to address "5" // KEY0 press --> clock pulse
		  SW[0] = 1'b1; SW[3:1] = 3'd5; SW[8:4] = 5'd1; KEY[0]= 0; #50; KEY[0]= 1; #50; 

        // - Read address 5
        SW[1] = 1'b1; SW[8:4] = 3'd5; #100;

        // - Write "2" to address 10
        SW[0] = 1'b1; SW[3:1] = 3'd10; SW[8:4] = 5'd2; KEY[0]= 0; #50; KEY[0]= 1; #50;

        // - Read adress 12
        SW[1] = 1'b1; SW[8:4] = 5'd2; 

        // SW9 ON --> switch to task3
        SW[9] = 1;

        // Task3 Input: wren = SW[0], data = SW[3:1], address = SW[8:4]
        // - Write "6" to address "2"
        SW[0] = 1'b1; SW[3:1] = 3'd6; SW[8:4] = 5'd2; repeat (2) @(posedge CLOCK_50);

        // - Write "1" to address "9"
        SW[0] = 1'b1; SW[3:1] = 3'd1; SW[8:4] = 5'd9; repeat (2) @(posedge CLOCK_50);

        // - Stop writing and observe read address counter
        KEY[3] = 0; @(posedge CLOCK_50); KEY[3] = 1; @(posedge CLOCK_50);// reset the counter
        SW[0]  = 1'b0; repeat (20) @(posedge CLOCK_50);
		  
        $stop;
    end

endmodule  // DE1_SoC_tb