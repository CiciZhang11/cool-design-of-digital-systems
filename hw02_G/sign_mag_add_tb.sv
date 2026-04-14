/* Testbench for Homework 2 Problem 3 */

module sign_mag_add_tb ();
  parameter N = 4;
  logic [N-1:0] sum;   // for the output of sign_mag_add - do not rename
  logic [N-1:0] data;  // for the output of sync_rom - do not rename

  // for you to implement BOTH sign_mag_add and sync_rom
  logic [N-1:0] a, b; // inputs of sign_mag_add
  sign_mag_add dut1(.a(a), .b(b), .sum(sum));
  logic clk;
  logic [7:0] addr; // input of sync_rom
  assign addr = {a, b}; // dut2 receiving same input as dut1
  sync_rom dut2(.clk(clk), .addr(addr), .data(data));

  // Set up the clock
  parameter T = 20;  // clock period
  initial begin
    clk <= 0;
    forever  #(T/2)  clk <= ~clk;
  end
  
  initial begin
  
    // for you to implement
	 a = 4'b0000; b = 4'b0000;  // initialize
	 // Some number + 0
    a = 4'b0001; b = 4'b0000; @(posedge clk); // +1 + 0 = +1
	 // pos + neg = 0
	 a = 4'b0001; b = 4'b1001; @(posedge clk); // +1 + (-1) = 0
	 //pos + neg > 0
	 a = 4'b0010; b = 4'b1001; @(posedge clk); // +2 + (-1) = +1 > 0
	 //pos + neg < 0
	 a = 4'b0001; b = 4'b1010; @(posedge clk); // +1 + (-2) = -1 < 0
	 //pos + pos (valid)
	 a = 4'b0001; b = 4'b0010; @(posedge clk); // +1 + (+2) = +3
	 //pos + pos (overflow)
	 a = 4'b0101; b = 4'b0011; @(posedge clk); // +5 + (+3) = +8
	 //neg + neg (valid)
	 a = 4'b1001; b = 4'b1010; @(posedge clk); // -1 + (-2) = -3
	 //neg + neg (overflow)
	 a = 4'b1101; b = 4'b1100; @(posedge clk); // -5 + (-4) = -9
	 
	 $stop;
  end  // initial
  
  initial begin
  $monitor("t=%0t clk=%b a=%b b=%b sum=%b data=%b",
           $time, clk, a, b, sum, data);               
  end
  
endmodule  // sign_mag_add_tb