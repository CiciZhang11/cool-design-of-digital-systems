// module ram32x8 for Task 2
// implement the memory ram32x8
// input: 5-bit Address, 8-bit word, and wren
// output: 8-bit DataOut: dout

module task2ram (
    input  logic clk,
    input  logic [4:0] address,
    input  logic [7:0] data,
    input  logic       wren,
    output logic [7:0] dout
);

    logic [7:0] memory_array [31:0]; // 32 * 8 array = 32 5-bit Address * 8-bit words


    always_ff @(posedge clk) begin
        if (wren) begin
            memory_array[address] <= data; // Write
        end

        dout <= memory_array[address]; // synchronous read
    end
endmodule