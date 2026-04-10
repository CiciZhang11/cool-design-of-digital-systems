module hex_decoder (
    input  logic [4:0] bin,
    input  logic       blank, 
    output logic [6:0] segments
);
    always_comb begin
        if (blank) segments = 7'b111_1111; // All segments off
        else begin
            case (bin)
                // Numbers 0-9
                5'd0: segments = 7'b100_0000;
                5'd1: segments = 7'b111_1001;
                5'd2: segments = 7'b010_0100;
                5'd3: segments = 7'b011_0000;
                5'd4: segments = 7'b001_1001;
                5'd5: segments = 7'b001_0010;
                5'd6: segments = 7'b000_0010;
                5'd7: segments = 7'b111_1000;
                5'd8: segments = 7'b000_0000;
                5'd9: segments = 7'b001_0000;

                5'd10: segments = 7'b000_1000; // A
                5'd11: segments = 7'b100_0110; // C
                5'd12: segments = 7'b000_0110; // E
                5'd13: segments = 7'b000_1110; // F
                5'd14: segments = 7'b100_0111; // L
                5'd15: segments = 7'b010_1111; // r
                5'd16: segments = 7'b100_0001; // U

                default: segments = 7'b111_1111;
            endcase// ends cases
        end// end else
    end//end combinational logic
endmodule // end module