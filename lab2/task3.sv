// module task3
// implement the memory
// input: 5-bit Address, 3-bit word, and wren
// output: 3-bit DataOut: dout_r

module task3 (
    input  logic clk, wren,
    input  logic [4:0] addr_w, addr_r,
    input  logic [2:0] data,
    output logic [2:0] dout_r
);

    ram32x3port2 r3 (
        .clock(clk),
		  .wren(wren_t3),
        .wraddress(addr_w),
        .rdaddress(addr_r),
        .data(din_t3),
        .q(dout_r)
    );

endmodule