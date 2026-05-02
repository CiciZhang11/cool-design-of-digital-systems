// This is a filter to remove noises. The general method we use here is
// averaging finite impulse response filter. We first divide sample in
// by N, and put it into fifo as the new tail entry and at the same time
// expose the oldest entry. These will be send to an accumulator whose input
// is the sum of the next incoming data value and its current stored value.
// so we get the average of the last N samples.
module fir_filter #(
    parameter DATA_WIDTH = 24, // audio sample width
    parameter N = 8,    // number of samples to average
    parameter ADDR_WIDTH = 3,
    parameter LOG2_N = 3  // for arithmetic right-shift
)(
    input  logic clk,
    input  logic reset,
    input  logic en, 
    input  logic [DATA_WIDTH-1:0] sample_in, // raw audio
    output logic [DATA_WIDTH-1:0] sample_out // filtered audio
);

    // 1. divide sample_in by N using arithmetic right shift
    logic signed [DATA_WIDTH-1:0] divided_in;
    assign divided_in = {{LOG2_N{sample_in[DATA_WIDTH-1]}},
                          sample_in[DATA_WIDTH-1 : LOG2_N]};
	 // 2. FIFO
	 // Use en for both read enable and write enable because we need to simultaously
	 // update both
    logic fifo_empty, fifo_full;
    logic [DATA_WIDTH-1:0] divided_out;

    fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) sample_fifo (
        .clk    (clk),
        .reset  (reset),
        .rd     (en), 
        .wr     (en),  // use the same enable signal for both read and write
        .empty  (fifo_empty),
        .full   (fifo_full),
        .w_data (divided_in), // push the newest
        .r_data (divided_out) // get the oldest
    );
	 // 3. Applying accumulator.
	 // update the same of the last N divided samples using 
    // acc <= acc + divided_in + (~divided_out + 1)
    logic signed [DATA_WIDTH-1:0] acc;

    always_ff @(posedge clk) begin
        if (reset) begin
            acc <= '0;
        end // end if
		  else if (en) begin
            // Add new divided sample; subtract oldest via two's complement
            acc <= acc + $signed(divided_in) + ($signed(~divided_out) + 1'b1);
        end // end else if
    end // end always_ff

    // 4. output sample_out
    assign sample_out = acc;

endmodule  // fir_filter