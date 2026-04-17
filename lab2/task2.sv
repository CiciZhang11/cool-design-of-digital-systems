// module task2
// implement the memory
// input: 5-bit Address, 3-bit word, and wren
// output: 3-bit DataOut: q

module task2 (
    input  logic       clock,
    input  logic [4:0] address,
    input  logic [2:0] data,
    input  logic       wren,
    output logic [2:0] q
);

    logic [2:0] memory_array [31:0]; // 32 * 3 array = 32 5-bit Address * 3-bit words

    always_ff @(posedge clock) begin
        if (wren) begin
            memory_array[address] <= data; // Write
				q <= data;
		  end
        else
		      q <= memory_array[address]; // Read
    end

endmodule