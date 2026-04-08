module car_detection(clk, reset, outer, inner, enter, exit);
    input  logic clk, reset, outer, inner;
    output logic enter, exit;
    
    typedef enum logic [2:0] {IDLE, enter1, enter2, enter3, exit1, exit2, exit3} state_t;
    state_t ps, ns;
    
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
                if(outer && inner) ns = enter2;
                else ns = enter1; 
            end //end enter1 case

            enter2: begin
                if(!outer && inner) ns = enter3;
                else ns = enter2;
            end //end enter2 case
            
            enter3: begin
                if (!outer && !inner) begin
                    ns = IDLE;
                    enter = 1'b1; //assign the output value enter as 1
                end
                else ns = enter3;
            end //end enter3 case
            
            exit1: begin
                if(outer && inner) ns = exit2;
                else ns = exit1;
            end //end exit1 case

            exit2: begin
                if(outer && !inner) ns = exit3;
                else ns = exit2;
            end //end exit2 case
            
            exit3: begin
                if(!outer && !inner) begin
                    ns = IDLE;
                    exit = 1'b1; //assign the output value exit as 1
                end
                else ns = exit3;
            end //end exit3 case
            
            default: ns = IDLE; 
            
        endcase //end listing ps cases 
    end //end combinational logic
    
    always_ff @(posedge clk) begin
        if(reset)
            ps <= IDLE;
        else
            ps <= ns;
    end //end sequential logic of flip-flop
    
endmodule // end module