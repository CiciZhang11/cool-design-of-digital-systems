// Car Counter Module
// Input: Car Enter --> incr
		  //Car Exit --> decr
// Output: counter store the number of cars (0–18)
// there are 3 states: increase, decrease, and unchange

module car_counter(counter, incr, decr, clk, reset);
	output logic [4:0] counter;
	input logic incr, decr, clk, reset;
	
	// output logic
	always_ff @(posedge clk) begin
		if (reset) begin
			counter <= 5'd0;
		end else begin
			if (incr && !decr && counter < 5'd18)		// increase
				counter <= counter + 5'd1;         
			else if (decr && !incr && counter > 5'd0) // decrease
				counter <= counter - 5'd1;     
			else
				counter <= counter;  // unchange
		end
	end // end output logic
	
	
endmodule // end module car_counter