/* Register file module for specified data and address bus widths.
 * Asynchronous read port (r_addr -> r_data) and synchronous write
 * port (w_data -> w_addr if w_en).
 * Memory is zero-initialized so simulation matches FPGA BRAM behavior
 * (on hardware, BRAM initializes to 0 automatically).
 * Note: always used instead of always_ff so that the initial block
 * can also drive array_reg without a compile error.
 */
module reg_file #(parameter DATA_WIDTH=8, ADDR_WIDTH=2)
                (clk, w_data, w_en, w_addr, r_addr, r_data);
  input  logic clk, w_en;
  input  logic [ADDR_WIDTH-1:0] w_addr, r_addr;
  input  logic [DATA_WIDTH-1:0] w_data;
  output logic [DATA_WIDTH-1:0] r_data;
  
  // array declaration (registers)
  logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

  // zero-initialize for simulation so reads before first write return 0,
  // matching FPGA BRAM behaviour. Ignored at synthesis.
  integer i;
  initial begin
    for (i = 0; i < 2**ADDR_WIDTH; i++)
      array_reg[i] = '0;
  end
  
  // write operation (synchronous)
  // always used instead of always_ff to allow coexistence with initial block
  always @(posedge clk)
     if (w_en)
       array_reg[w_addr] <= w_data;
  
  // read operation (asynchronous)
  assign r_data = array_reg[r_addr];
  
endmodule  // reg_file