// sync_rom module
// truthtable4.txt has16 rows and 16 columns 
// 256 4-bit data
// 8-bit address * 4-bit data

module sync_rom (input  logic clk,
                 input  logic [7:0] addr,  // 8-bit address
                 output logic [3:0] data); // 4-bit data
  
  // signal declaration
  logic [3:0] rom [0:255];
  
  // load binary values from a dummy text file into ROM
  initial
    $readmemh("truthtable4.txt", rom); // changed the file name
	 // read memory hexadecimal
  
  // synchronously reads out data from requested addr
  always_ff @(posedge clk)
    data <= rom[addr];
  
endmodule  // sync_rom
