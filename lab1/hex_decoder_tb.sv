/* testbench for the hex_decoder */

module hex_decoder_tb();

    logic [4:0] bin;
    logic blank;
    logic [6:0] segments;

    // instantiate DUT
    hex_decoder dut(.*);

    initial begin

        // Test blank = 1 
        blank = 1; bin = 5'd0; #10;
                  bin = 5'd5; #10;
                  bin = 5'd10; #10;

        // Test numbers 0–9
        blank = 0;
        bin = 5'd0;  #10;
        bin = 5'd1;  #10;
        bin = 5'd2;  #10;
        bin = 5'd3;  #10;
        bin = 5'd4;  #10;
        bin = 5'd5;  #10;
        bin = 5'd6;  #10;
        bin = 5'd7;  #10;
        bin = 5'd8;  #10;
        bin = 5'd9;  #10;

        // Test letters
        bin = 5'd10; #10; // A
        bin = 5'd11; #10; // C
        bin = 5'd12; #10; // E
        bin = 5'd13; #10; // F
        bin = 5'd14; #10; // L
        bin = 5'd15; #10; // r
        bin = 5'd16; #10; // U

        // Test default case
        bin = 5'd31; #10;

        $stop;
    end

endmodule