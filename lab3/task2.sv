// Task 2 – Play a Tone from Memory

module task2 #(
    parameter ROM_SIZE = 48000
) (
    input  logic clk,
    input  logic reset,
    input  logic write_ready,
    output logic [23:0] rom_data
);

    logic [15:0] rom_addr;

    rom48kx24 rom(
        .address(rom_addr),
        .clock(clk),
        .q(rom_data)
    );

	
    always_ff @(posedge clk) begin
        if (reset) begin
            rom_addr <= 16'd0;
        end //end if
        else if (write_ready) begin
            if(rom_addr == (ROM_SIZE-1)) begin
                rom_addr <= 16'd0;
            end //end inner if
            else begin
                rom_addr <= rom_addr + 1'b1;
            end //end inner else
        end //end outter else if
    end // end always_ff
	
endmodule // end module Task 2