/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 *
 */
module line_drawer(clk, reset, x0, y0, x1, y1, x, y, done);
	input logic clk, reset;
	input logic [10:0]	x0, y0, x1, y1;
	output logic done;
	output logic [10:0]	x, y;
	
	/* You'll need to create some registers to keep track of things
	 * such as error and direction.
	 */
	logic signed [11:0] error;  // example - feel free to change/delete
	logic signed [11:0] dx, dy, y_step; 
	// store the unswapped version
	logic [10:0] x0r, y0r, x1r, y1r; // registers after swapping
	logic is_steep;
	logic [10:0] cx, cy; // internal x, y before swapping
	
   typedef enum logic [2:0] {S_RESET, S_SWAP, S_CALC, S_DRAW, S_DONE} state_t;
   state_t ps, ns;


always_comb begin
    case (ps)
        S_RESET: ns = S_SWAP;
        S_SWAP:  ns = S_CALC;
        S_CALC:  ns = S_DRAW;
        S_DRAW:  ns = (cx == x1r) ? S_DONE : S_DRAW;
        S_DONE:  ns = S_DONE; // Wait here until external reset
        default: ns = S_RESET;
    endcase // end ps case
end // end always_comb
always_comb begin
    if (is_steep) begin
        x = cy;
        y = cx;
    end else begin //end if
        x = cx;
        y = cy;
    end // end else
end // end always_comb

always_ff @(posedge clk) begin
    if (reset) begin
        ps <= S_RESET;
        done <= 0;
        cx <= 0; cy <= 0;
    end else begin // end if
        ps <= ns; // Move to next state
        
        case (ps)
            S_RESET: begin
                done <= 0;
            end //end S_RESET
            
           S_SWAP: begin
					if ((y1 > y0 ? y1 - y0 : y0 - y1) > (x1 > x0 ? x1 - x0 : x0 - x1)) begin
						is_steep <= 1;
						// here we combined the 2 swaps in pseudocode
						if (y0 > y1) begin 
							x0r <= y1; y1r <= x0; // swap(x0,y1)
							x1r <= y0; y0r <= x1; // swap(x1,y0)
						end else begin // end if 
							x0r <= y0; y0r <= x0; // swap(x0,y0)
							x1r <= y1; y1r <= x1; // swap(x1,y1)
						end // end else
						 
					end else begin
						is_steep <= 0;
						 
						if (x0 > x1) begin
							x0r <= x1; x1r <= x0; // swap(x0,x1)
							y0r <= y1; y1r <= y0; // swap(y0,y1)
						end else begin //end if
							x0r <= x0; y0r <= y0;
							x1r <= x1; y1r <= y1;
						end // end else
					end // end else
				end // end S_SWAP
            
            S_CALC: begin
               dx <= $signed({1'b0, x1r}) - $signed({1'b0, x0r});
               dy <= (y1r >= y0r) ? $signed({1'b0, y1r}) - $signed({1'b0, y0r}) 
                                  : $signed({1'b0, y0r}) - $signed({1'b0, y1r});
                
               error <= -($signed({1'b0, x1r} - {1'b0, x0r}) >>> 1);
               y_step <= (y0r < y1r) ? 12'sd1 : -12'sd1;
                
               cx <= x0r;
               cy <= y0r;
            end // end S_CALC
            
            S_DRAW: begin
               // advance to next pixel
               if (cx != x1r) begin
                   cx <= cx + 11'd1;
                   error <= error + dy;
                   if ((error + dy) >= 0) begin
                      cy <= $signed({1'b0, cy}) + y_step;
                      error <= error + dy - dx;
                  end // end if
               end // end if
            end // end S_DRAW
            
            S_DONE: begin
               done <= 1;
            end // end S_DONE
        endcase // end case
	   end // end else
		
	end  // always_ff
	
endmodule  // line_drawer

