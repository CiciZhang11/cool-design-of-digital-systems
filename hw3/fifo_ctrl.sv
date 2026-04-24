/* FIFO controller to manage a register file as a circular queue.
 * Manipulates output read and write addresses based on 1-bit
 * read (rd) and write (wr) requests and current buffer status
 * signals empty and full.
 */
module fifo_ctrl #(parameter ADDR_WIDTH=4)
                 (clk, reset, rd, wr, empty, full, w_addr, r_addr, half_sel);
  
  input  logic clk, reset, rd, wr;
  output logic empty, full, half_sel; // add a output half_sel
  output logic [ADDR_WIDTH-1:0] w_addr, r_addr;
  
  // signal declarations
  logic [ADDR_WIDTH-1:0] rd_ptr, rd_ptr_next;
  logic [ADDR_WIDTH-1:0] wr_ptr, wr_ptr_next;
  logic empty_next, full_next;
  logic half_sel_next; // next state of half_sel
  
  // output assignments
  assign w_addr = wr_ptr;
  assign r_addr = rd_ptr;
  
  // fifo controller logic
  always_ff @(posedge clk) begin
    if (reset)
      begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        full   <= 0;
        empty  <= 1;
		  half_sel <= 0; // when rest is on, half_sel = 0, selecting upper half
      end
    else
      begin
        wr_ptr <= wr_ptr_next;
        rd_ptr <= rd_ptr_next;
        full   <= full_next;
        empty  <= empty_next;
		  half_sel <= half_sel_next;
      end
  end  // always_ff
  
  // next state logic
  always_comb begin
    // default to keeping the current values
    rd_ptr_next = rd_ptr;
    wr_ptr_next = wr_ptr;
    empty_next = empty;
    full_next = full;
	 half_sel_next = half_sel;
	 
    case ({rd, wr})

      2'b11: begin  // read and write
        if (~empty) begin
          if (half_sel == 1'b0) begin
            half_sel_next = 1'b1; // read upper half, stay same address
          end else begin
            half_sel_next = 1'b0; // read lower half
            rd_ptr_next = rd_ptr + 1'b1;
          end // end else
        end

        if (~full) begin
          wr_ptr_next = wr_ptr + 1'b1;
          empty_next = 0;
        end
      end
		
      2'b10: begin  // read
        if (~empty)
          begin
            if (half_sel == 1'b0) begin
              half_sel_next = 1'b1; // read upper half only
            end else begin
              half_sel_next = 1'b0; // read lower half
              rd_ptr_next = rd_ptr + 1'b1; // remove entry
              if (rd_ptr_next == wr_ptr)
                empty_next = 1;
              end
				  full_next = 0;
            end
		end
		
      2'b01:  // write
        if (~full)
          begin
            wr_ptr_next = wr_ptr + 1'b1;
            empty_next = 0;
            if (wr_ptr_next == rd_ptr)
              full_next = 1;
          end
      2'b00: ; // no change
    endcase
  end  // always_comb
  
endmodule  // fifo_ctrl
