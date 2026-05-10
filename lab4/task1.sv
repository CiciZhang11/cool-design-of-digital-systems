// This is the top level of task 1 ASMD
module task1 (
	
   input  logic [7:0] SW, // 8 bits A
   input  logic [3:0] KEY, // KEY[0]:reset (active-low), KEY[3]:start
   input  logic CLOCK_50,
   output logic [6:0] HEX0, // bits count display
   output logic [9:0] LEDR    // LEDR9: finish
);
	// use user_input to handle metastability of key3
	logic s_sync;
   user_input sync_s (
      .clk(CLOCK_50),
		.reset(~KEY[0]),
      .key  (~KEY[3]), //active low
		.out (s_sync)
   );

   logic [7:0] A_internal;
   logic [3:0] result;
   logic  load_A, clr_result, incr_result, shift_A, done;

	task1_controller #(.N(8)) ctrl (
		.clk(CLOCK_50),
      .reset(KEY[0]),
      .s(s_sync),
      .A(A_internal),
      .load_A(load_A),
      .clr_result(clr_result),
      .incr_result(incr_result),
      .shift_A(shift_A),
      .done(done)
   );

   task1_datapath #(.N(8)) dpath (
      .clk(CLOCK_50),
      .reset(KEY[0]),
      .A_in(SW),
      .load_A(load_A),
      .clr_result(clr_result),
      .incr_result(incr_result),
      .shift_A (shift_A),
      .A(A_internal),
      .result (result)
   );

   seg7 disp (
      .hex(result),
      .leds(HEX0)
   );

   // All other LEDs off; LEDR9 = done flag
   assign LEDR [8:0] = 9'b0;
   assign LEDR[9] = done;
endmodule