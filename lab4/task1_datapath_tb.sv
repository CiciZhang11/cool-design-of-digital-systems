// This is the testbench for task1_datapath
// The idea of this testbench is to set the signals manually and to see
// if all the data flows as expected. we tested 5 cases here.
// 1. load A = 8'b10110101, a case with both contigurous and seperated 
// 1s and result in 5
// 2. load A = 8'b10110110, a case with least significant number =0(different
// with case 1), and result in 5.
// 3. load A = 8'b11111111, a case with all 1s,
// 4. load A = 8'b00000000, a case with al 0s,
// 5. load A = 8'b10110101 but clear result in the middle.
module task1_datapath_tb();
	parameter N=8;
	logic clk, reset;
	logic [N-1:0] A_in;
	logic load_A, clr_result, incr_result, shift_A;
	logic [N-1:0] A;
	logic [3:0] result;
	
	task1_datapath #(.N(N)) dut (.*);
	
	parameter period = 100;
   initial begin
      clk <= 0;
      forever  #(period/2) clk <= ~clk;

   end
	
	initial begin
      // Reset
      reset = 0; {load_A, clr_result, incr_result, shift_A} = '0;
      A_in ='0; @(posedge clk);
      reset = 1; @(posedge clk);

      // load A = 8'b10110101 (5 ones)
      A_in = 8'b10110101; load_A = 1; clr_result = 1;
      shift_A = 0; incr_result = 0;  @(posedge clk);
      load_A = 0; clr_result = 0;
		@(posedge clk);
		repeat(8) begin
			#1;
         incr_result = A[0]; shift_A = 1; @(posedge clk);
      end
      shift_A = 0; incr_result = 0;
		@(posedge clk);
		@(posedge clk);
		
      // load A = 8'b10110110 (5 ones)
      A_in = 8'b10110110; load_A = 1; clr_result = 1;
      shift_A = 0; incr_result = 0;  @(posedge clk);
      load_A = 0; clr_result = 0;
		
		@(posedge clk);
       // Shift 8 times, incrementing when a0=1
      repeat(8) begin
			#1;
			incr_result = A[0]; shift_A = 1; @(posedge clk);
      end
      shift_A = 0; incr_result = 0;
		@(posedge clk);
		@(posedge clk);

      // load A = 8'b11111111 (8 ones), verify result = 8
      A_in = 8'b11111111; load_A = 1; clr_result = 1; @(posedge clk);
      load_A = 0; clr_result = 0;
		
		@(posedge clk);
      repeat(8) begin
			#1;
        incr_result = A[0]; shift_A = 1; @(posedge clk);
      end
      shift_A = 0; incr_result = 0;
		
		@(posedge clk);
		@(posedge clk);

      // load A = 8'b00000000 (0 ones), verify result stays 0
      A_in = 8'b00000000; load_A = 1; clr_result = 1; @(posedge clk);
      load_A = 0; clr_result = 0;
		
		@(posedge clk);
      repeat(8) begin
			#1;
        incr_result = A[0]; shift_A = 1; @(posedge clk);
      end
      shift_A = 0; incr_result = 0;
		@(posedge clk);
		@(posedge clk);
		
		// clear result without load A
		A_in = 8'b10110101; load_A = 1; clr_result = 1; @(posedge clk);
      load_A = 0; clr_result = 0;
		
		@(posedge clk);
      repeat(4) begin
			#1;
         incr_result = A[0]; shift_A = 1; @(posedge clk);
      end
      shift_A = 0; incr_result = 0;
      clr_result = 1; @(posedge clk); // clear mid-count
      clr_result = 0;
      @(posedge clk);
      $stop();
    end

endmodule // task1_datapath_tb