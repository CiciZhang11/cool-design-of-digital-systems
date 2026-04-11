// Top-level moduel for the DE1_SoC board implementation
//This module connects the car detection FSM and car counter to the physical hardware.
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, V_GPIO);
	input  logic       CLOCK_50;  // 50MHz clock
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;  // active low
	output logic [9:0] LEDR;
	inout  logic [35:0] V_GPIO;  // expansion header 0 (LabsLand board)


    logic reset, outer, inner;
    logic enter_pulse, exit_pulse;
    logic [4:0] count;

    // Wiring to GPIO
    assign outer = V_GPIO[23]; // SW1
    assign inner = V_GPIO[24]; // SW2
    assign reset = V_GPIO[29]; // SW3
	 
	 // Assign V_GPIO[34] (LED1) to V_GPIO[23] (switch1)
	 assign V_GPIO[34] = V_GPIO[23];
	 // Assign V_GPIO[35] (LED2) to V_GPIO[24] (switch2)
	 assign V_GPIO[35] = V_GPIO[24];



    // car detection FSM to determine if a car enterd or exited
    car_detection fsm (
        .clk(CLOCK_50), .reset(reset),
        .outer(outer), .inner(inner),
        .enter(enter_pulse), .exit(exit_pulse)
    );

    // car counter FSM to counter the occupancy of the parking lot
    car_counter counter_unit (
        .clk(CLOCK_50), .reset(reset),
        .incr(enter_pulse), .decr(exit_pulse),
        .counter(count)
    );

     //display
     logic [4:0] h5, h4, h3, h2, h1, h0; 
    logic b5, b4, b3, b2, b1, b0;

	// Determines what text or numbers to show on the HEX displays
    always_comb begin
        // Default: Show numeric count
        h1 = (count >= 10) ? 5'd1 : 5'd0;
        h0 = (count % 10);
        b1 = (count < 10); b0 = 0;
        b5 = 1; b4 = 1; b3 = 1; b2 = 1;
        h5=5'd0; h4=5'd0; h3=5'd0; h2=5'd0;

        if (count == 0) begin
            // "CLEAR" + "0"
            h5=5'd11; h4=5'd14; h3=5'd12; h2=5'd10; h1=5'd15; h0=5'd0;
            b5=1'd0; b4=1'd0; b3=1'd0; b2=1'd0; b1=1'd0; b0=1'd0;
        end //end if
        else if (count >= 18) begin
            // "FULL" + "18"
            h5=5'd13; h4=5'd16; h3=5'd14; h2=5'd14; h1=5'd1; h0=5'd8;
            b5=1'd0; b4=1'd0; b3=1'd0; b2=1'd0; b1=1'd0; b0=1'd0;
        end//end else if
    end// end always_comb

    // decoders, convert 5-bits values into 7 segment patterns.
    hex_decoder d5 (h5, b5, HEX5);
    hex_decoder d4 (h4, b4, HEX4);
    hex_decoder d3 (h3, b3, HEX3);
    hex_decoder d2 (h2, b2, HEX2);
    hex_decoder d1 (h1, b1, HEX1);
    hex_decoder d0 (h0, b0, HEX0);

endmodule//end module DE1
