/* FIFO buffer FWFT implementation for specified data and address
 * bus widths based on internal register file and FIFO controller.
 * Inputs: 1-bit rd removes head of buffer and 1-bit wr writes
 * w_data to the tail of the buffer.
 * Outputs: 1-bit empty and full indicate the status of the buffer
 * and r_data holds the value of the head of the buffer (unless empty).
 */
module fifo #(parameter DATA_WIDTH=8, ADDR_WIDTH=4)
            (clk, reset, rd, wr, empty, full, w_data, r_data);

  input  logic clk, reset, rd, wr;
  output logic empty, full;
  input  logic [2*DATA_WIDTH-1:0] w_data; // 2* DATA_WIDTH
  output logic [DATA_WIDTH-1:0] r_data;
  
  // signal declarations
  logic [ADDR_WIDTH-1:0] w_addr, r_addr;
  logic w_en;
  logic half_sel;
  logic [2*DATA_WIDTH-1:0] r_word;
  
  // enable write only when FIFO is not full
  // or if reading and writing simultaneously
  assign w_en = wr & (~full | rd);
  
  // instantiate FIFO controller and register file
  fifo_ctrl #(ADDR_WIDTH) c_unit (
    .clk(clk),
    .reset(reset),
    .rd(rd),
    .wr(wr),
    .empty(empty),
    .full(full),
    .w_addr(w_addr),
    .r_addr(r_addr),
    .half_sel(half_sel)
  );
  
  reg_file #(DATA_WIDTH, ADDR_WIDTH) r_unit (
    .clk(clk),
    .w_data(w_data),
    .w_en(w_en),
    .w_addr(w_addr),
    .r_addr(r_addr),
    .r_data(r_word)
  );
  
  // read upper half first, then lower half
  assign r_data = (half_sel == 1'b0) ?
                  r_word[2*DATA_WIDTH-1:DATA_WIDTH] : 
                  r_word[DATA_WIDTH-1:0];
  
endmodule  // fifo