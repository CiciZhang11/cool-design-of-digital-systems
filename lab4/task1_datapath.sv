// This is the datapath for task 1 ASMD
module task1_datapath #(parameter N = 8) (
	input logic clk, reset,
	input logic [N-1:0] A_in,
	input logic load_A, clr_result, incr_result, shift_A,
	output logic [N-1:0] A,
	output logic [3:0] result // count
);
	
	always_ff@(posedge clk) begin
		if(~reset) begin
			result <= '0;
			A<= '0;
		end else begin
			if (clr_result) 
				result <= '0;
			else if(shift_A&& incr_result)
				result<= result + 4'd1;
				
			if (load_A)     
				A <= A_in;
			else if (shift_A)
				A <= A>>1; // right shift
		end //end else

    end // end always_ff
endmodule // task1_datapath
