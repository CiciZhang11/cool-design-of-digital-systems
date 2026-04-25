/* Testbench for Homework 3 Problem 1 */
module fifo_tb ();

  logic clk, reset, rd, wr;
  logic empty, full;
  logic [15:0] w_data;
  logic [7:0]  r_data;

  parameter CLOCK_PERIOD = 10;

  fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) dut (.*);

  // clock
  initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
  end

  initial begin
    rd = 0;
    wr = 0;
    reset = 0;
    w_data = 16'h0000;

    // 1. Reset FIFO 
    reset = 1; @(posedge clk);
    reset = 0; @(posedge clk);
    $display("1. after Reset FIFO: empty=%b full=%b", empty, full);

    // 2. Try to read while empty 
    rd = 1; @(posedge clk); 
	 rd = 0; @(posedge clk);
    $display("Read while empty: empty=%b full=%b r_data=%h", empty, full, r_data);

    // 3. Write ABCD, no read 
    wr = 1; w_data = 16'hABCD; rd = 0; @(posedge clk);
    wr = 0; @(posedge clk);
    $display("After write ABCD: empty=%b full=%b", empty, full);

    // 4. read upper half 
    rd = 1; @(posedge clk);
    rd = 0; @(posedge clk);
    $display("Read upper half: r_data=%h, expected AB", r_data);

    // 5. read lower half 
    rd = 1; @(posedge clk);
    rd = 0; @(posedge clk);
    $display("Read lower half: r_data=%h, expected CD", r_data);
	 
	 // 6. write ABCD again, and read
    wr = 1; w_data = 16'hABCD; rd = 1; @(posedge clk);
	 wr = 0; rd = 0; @(posedge clk);
    @(posedge clk);

    rd = 1; @(posedge clk);
    rd = 0; @(posedge clk);
    $display("Write again then read: r_data=%h, expected AB", r_data);
	 
	 // 7. Reset and Write ABCD 16 times, more than FIFO depth
    reset = 1; @(posedge clk);
    reset = 0; @(posedge clk);
	 $display("After reset: empty=%b full=%b", empty, full);
    w_data = 16'hABCD;
	 
	 wr = 1; repeat (16) @(posedge clk);
    wr = 0; @(posedge clk);
    $display("After 16 writes: empty=%b full=%b", empty, full);

    // one extra write when full
    wr = 1; w_data = 16'hABCD; @(posedge clk);
    wr = 0; @(posedge clk);
    $display("After extra write: empty=%b full=%b", empty, full);

    $stop;
  end  // initial
  
endmodule  // fifo_tb