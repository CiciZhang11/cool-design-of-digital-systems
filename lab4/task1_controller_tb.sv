// This is the testbench for task1_controller. 
// The idea of the testbench is that we will force the A input manually 
// to pretent it's shifting, and to watch how the controller reacts.
// we tested 3 cases here. 
// 1. when A=0, it should immediately hit the exit
// 2. reset during S_SHIFT
// 3. reset during S_DONE
// 4. normal shifting loop, check exiting to S_DONE
// at the same time, check the logic S_DONE: ns=s?S_DONE:S_IDLE. 
// test when holding start, whether the state machine will stay in S_DONE.
module task1_controller_tb();
    parameter N = 8;
    
    // Testbench signals
    logic s, clk, reset;
    logic [N-1:0] A;
    logic load_A, clr_result, incr_result, shift_A, done;
    
    // Instantiate the controller
    task1_controller #(.N(N)) dut (
        .s(s), .clk(clk), .reset(reset), .A(A),
        .load_A(load_A), .clr_result(clr_result), 
        .incr_result(incr_result), .shift_A(shift_A), .done(done)
    );
    
    // Clock generation
    parameter period = 10;
    initial begin
        clk = 0;
        forever #(period/2) clk = ~clk;
    end
    
    initial begin
        // Initialize
        reset = 0; s = 0; A = 8'b00000000;
        @(posedge clk);
        #1; reset = 1; 
        @(posedge clk);
		  
		  // 1. when A=0, immediately exit
        A = 8'b00000000;
        #1; s = 1; @(posedge clk);
        #1; s = 0; @(posedge clk);
        
        // Next cycle should be S_DONE, done should be 1
        @(posedge clk);
        // return to S_IDLE
        @(posedge clk); 
        @(posedge clk);

		  // 2. while in S_SHIFT, reset has been triggered.
        A = 8'b11111111; 
        #1; s = 1; @(posedge clk); // Trigger start
        #1; s = 0; @(posedge clk); // Now in S_SHIFT
        
        #1; A = 8'b01111111; @(posedge clk);
        #1; A = 8'b00111111; @(posedge clk);
        
        // reset
        #1; reset = 0; @(posedge clk);        
        #1; reset = 1; @(posedge clk);


        // 3. reset during S_DONE
        A = 8'b00000010; 
        #1; s = 1; @(posedge clk); 
        #1; A = 8'b00000001; @(posedge clk); // Triggers S_DONE next cycle
        
        @(posedge clk); 

        #1; reset = 0; @(posedge clk);// done=1
        
        #1; reset = 1; s = 0; @(posedge clk);
		  // 4. normal shift completion & stuck start button
        A = 8'b00000100; // Small number to shift
        #1; s = 1; @(posedge clk); // S_IDLE to S_SHIFT
        
        // Simulate shifting down while holding 's' high
        #1; A = 8'b00000010; @(posedge clk);
        #1; A = 8'b00000001; @(posedge clk);
        #1; A = 8'b00000000; @(posedge clk); //S_DONE
        @(posedge clk); //'done' should be 1.
		  @(posedge clk); 
        
        // Hold 's' high for a few cycles. It should NOT return to S_IDLE.
        repeat(3) @(posedge clk);
        
        // Now drop 's'. It should return to S_IDLE.(look at clr_result val)
        #1; s = 0; @(posedge clk);
        @(posedge clk);
        $stop();
    end
endmodule