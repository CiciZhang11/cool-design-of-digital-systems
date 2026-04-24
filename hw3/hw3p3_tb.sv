/* Testbench for Homework 3 Problem 3 */
module hw3p3_tb ();

  // for you to implement
  logic clk, reset, X;
  logic Ya, Yb, Yc, Z1, Z2;

  hw3p3 dut (.*);

  // clock
  parameter CLOCK_PERIOD = 10;

  initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
  end

  initial begin
    // Test reset signal
    reset = 1; X = 0; @(posedge clk);
	 reset = 0;

    // Test Ya with X = 0
    X = 0; @(posedge clk);

    // Test Ya with X = 1, should go to Yb
    X = 1; @(posedge clk);

    // Test Yb with X = 0, should go back to Ya
    X = 0; @(posedge clk);

    // Go to Yb again
    X = 1; @(posedge clk);

    // Test Yb with X = 1, should go to Yc
    X = 1; @(posedge clk);

    // Test Yc with X = 0, should go to Ya, output is Z1 
    X = 0; @(posedge clk);

    // Go to Yb then Yc again
    X = 1; @(posedge clk); // go to Yb
    X = 1; @(posedge clk); // go to Yc

    // Test Yc with X = 1, should stay in Yc, output is Z2 
    X = 1; @(posedge clk);
	 @(posedge clk); // wait one clk

    $stop;
  end  // initial

endmodule  // hw3p3_tb
