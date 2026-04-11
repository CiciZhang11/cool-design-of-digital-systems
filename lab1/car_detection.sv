// This module is to detect if a car just entered or exited a parking space. It takes in the inputs of 2 sensors alongside with
// clock and reset signal, and output signal indicating if the car entered or exited.
module car_detection(clk, reset, outer, inner, enter, exit);
    input  logic clk, reset, outer, inner;
    output logic enter, exit;
    
    typedef enum logic [3:0] {IDLE, enter1, enter2, enter3, exit1, exit2, exit3, E_DONE, X_DONE} state_t;
    state_t ps, ns;
    // Combinational logic for next state and output generation
    always_comb begin
        ns = ps;    // Default: stay in current state
        enter = 1'b0;
        exit = 1'b0;
        
        case(ps)
            IDLE: begin
                if(outer && !inner) ns = enter1;
                else if(!outer && inner) ns = exit1;
                else ns = IDLE;
            end //end IDLE case
            
            enter1: begin
               if(outer && inner)   ns = enter2;
               else if(!outer && !inner)  ns = IDLE;   // Car backed out
               else  ns=enter1;
            end //end enter1 case

            enter2: begin
                if(!outer && inner) ns = enter3;
					 else if(outer && !inner) ns = enter1;
                else ns = enter2;
            end //end enter2 case
            
            enter3: begin // Inner blocked
                if (!outer && !inner)    ns = E_DONE; // Sequence complete
                else if (outer && inner) ns = enter2;
                else                     ns = enter3;
            end

            E_DONE: begin
                enter = 1'b1;     
                ns = IDLE; 
            end
            
            exit1: begin
                if(outer && inner) ns = exit2;
					 else if(!outer && !inner)ns = IDLE;
                else ns = exit1;
            end //end exit1 case

            exit2: begin
                if(outer && !inner) ns = exit3;
					 else if(!outer && inner) ns = exit1;
                else ns = exit2;
            end //end exit2 case
            
            exit3: begin // Outer blocked
                if(!outer && !inner) ns = X_DONE; // Sequence complete
                else if(outer && inner) ns = exit2;
					 else ns = exit3;
			end //end exit3 case

            X_DONE: begin
                exit = 1'b1; 
                ns = IDLE; 
			end //end X_DONE case
            
            default: ns = IDLE; 
            
        endcase //end listing ps cases 
    end //end always_comb

	
	//Sequential logic to update state memory on clock edge. if reset, go to IDLE(initial state)
	//else, go to the next state.
    always_ff @(posedge clk) begin
        if(reset)
            ps <= IDLE;
        else
            ps <= ns;
    end //end always_ff
    
endmodule // end module
