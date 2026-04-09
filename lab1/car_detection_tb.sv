module car_detection_testbench();

	logic clk, reset, outer, inner, enter, exit;
	
	car_detection dut(.clk(clk), .reset(reset),.outer(outer), .inner(inner),
        .enter(enter),.exit(exit));
		  
	parameter period = 100;
   initial begin
      clk <= 0;
      forever  #(period/2) clk <= ~clk;
   end  // initial clock
	
	initial begin
		reset = 1; outer=0; inner=0; @(posedge clk);
		reset =0;@(posedge clk);
		//Test Enter
		outer = 1; inner = 0; repeat(3) @(posedge clk); // outer blocked
      outer = 1; inner = 1; repeat(3) @(posedge clk); // both blocked
      outer = 0; inner = 1; repeat(3) @(posedge clk); // inner blocked
      outer = 0; inner = 0; repeat(1) @(posedge clk); // clear (Should see 'enter' pulse)
      outer = 0; inner = 0;
        
      repeat(5) @(posedge clk);

      //Test Exit
      outer = 0; inner = 1; repeat(3) @(posedge clk); // inner blocked
      outer = 1; inner = 1; repeat(3) @(posedge clk); // both blocked
      outer = 1; inner = 0; repeat(3) @(posedge clk); // outer blocked
      outer = 0; inner = 0; repeat(1) @(posedge clk); // clear (Should see 'exit' pulse)
      outer = 0; inner = 0;
    
      repeat(5) @(posedge clk);
		//False sequence
      outer = 1; inner = 0; repeat(3) @(posedge clk); // outer blocked
      outer = 1; inner = 1; repeat(3) @(posedge clk); // both blocked
      outer = 1; inner = 0; repeat(3) @(posedge clk); // moves backward to outer
      outer = 0; inner = 0; repeat(3) @(posedge clk); // clear
      outer = 0; inner = 0;

        
      $stop; // Pause simulation in ModelSim
   
	end  // initial
	



endmodule// end module
