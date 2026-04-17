// module named task1
// used to instantiates the ram32x3 module
// input: 5-bit Address, 3-bit word, and wren
// output: 3-bit DataOut: q

module task1 (
    input  logic       clock,
    input  logic [4:0] address,
    input  logic [2:0] data,
    input  logic       wren,
    output logic [2:0] q
);

    ram32x3 r1 (
        .address(address),
        .clock  (clock),
        .data   (data),
        .wren   (wren),
        .q      (q)
    );

endmodule