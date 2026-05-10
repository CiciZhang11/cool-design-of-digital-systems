// This is the controller for task1 ASMD
module task1_controller #(parameter N = 8) (
	input logic s, clk, reset, //reset makes the result = 0 and load A again
	input logic [N-1:0] A,
	output logic load_A, clr_result, incr_result, shift_A,
	output logic done
	
);
	typedef enum logic [1:0] {S_IDLE, S_SHIFT, S_DONE} state_t;
	state_t ps, ns;
	
	always_ff@(posedge clk) begin
		if(~reset)
			ps<= S_IDLE;
		else
			ps<=ns;
	end // end always_ff
	
	// next state logic
	always_comb begin
		ns=ps;
		case (ps)
			S_IDLE: ns = s? S_SHIFT : S_IDLE;
			S_SHIFT: ns = (A == '0) ? S_DONE : S_SHIFT;
			//S_SHIFT: ns = (A == {{N-1{1'b0}}, 1'b1} || A == '0) ? S_DONE : S_SHIFT;
			S_DONE: ns = s? S_DONE : S_IDLE;
			default: ns = S_IDLE;
		endcase // end case
	end // end always_comb
	//output assignment

	always_comb begin
      // defaults
      load_A = 1'b0;
      clr_result = 1'b0;
      incr_result= 1'b0;
      shift_A = 1'b0;
      done = 1'b0;

      case (ps)
			S_IDLE: begin
				load_A = 1'b1; // continuously latch A while idle
				clr_result = 1'b1; // keep result cleared
			end // end S_IDLE
         S_SHIFT: begin
				incr_result = A[0];  // count it when a0=1
				shift_A = 1'b1;
			end //end S_SHIFT
         S_DONE: begin
				done = 1'b1;
         end //end S_DONE
      endcase // end case(ps)
    end // end always_comb
	
endmodule // task1_controller
	