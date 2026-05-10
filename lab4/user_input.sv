// Coded by Cici Zhang
// This file is aim to read user input and avoid metastability
// Using method 2 while adding an extra flipflop: Flop holds previous key state, Output true when key is currently pressed and wasn’t previously pressed

module user_input (clk, reset, key, out);
    input clk, reset, key;
    output out;
   
    logic w0, w1, delay;

    always_ff @(posedge clk) begin
        if (reset) begin
            w0 <= 0;
            w1 <= 0;
            delay <= 0;
        end else begin
            w0 <= key;  
            w1 <= w0;
            delay <= w1;
        end
    end

    assign out = w1 & ~delay;
endmodule

// Test user_input module
module user_input_testbench();
	logic  clk, reset, w;
	logic  out;

// Instantiation
	user_input dut (clk, reset, w, out);

// Simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

// Set up
// Each line is a clock cycle.
	initial begin
		w <= 0;             @(posedge clk);
		reset <= 1;         @(posedge clk); 
		reset <= 0;         @(posedge clk);
									@(posedge clk);
		w <= 1;             @(posedge clk);	
		w <= 0;             @(posedge clk);
                   @(posedge clk);
                   @(posedge clk);

		w <= 1;             @(posedge clk);
                   @(posedge clk);
                   @(posedge clk);
                   @(posedge clk);
                   @(posedge clk);
                   @(posedge clk);

		w <= 0;             @(posedge clk);
                   @(posedge clk);
                   @(posedge clk);
		$stop; // End the simulation.
	end
endmodule