// This is a testbench for fir_filter
// 1. test reset clears accumulator to 0
// 2. test startup phase(not fully occupied, out=0)
// 3. regular sliding window.
// 4. test negative/signed samples, i.e.arithmetic right shift and two's complement negation
// 5. test sample noises.
// 6. test reset again
// 7. test enable for read/write, test if simultaneous.
module fir_filter_tb();
    localparam DATA_WIDTH = 24;
    localparam N          = 8;
    localparam ADDR_WIDTH = 4;
    localparam LOG2_N     = 3;

    logic                  clk, reset, en;
    logic [DATA_WIDTH-1:0] sample_in;
    logic [DATA_WIDTH-1:0] sample_out;

    fir_filter #(.DATA_WIDTH(DATA_WIDTH), .N(N), .ADDR_WIDTH(ADDR_WIDTH), .LOG2_N(LOG2_N)) dut (.*);

    // simulated clock
    parameter period = 100;
    initial begin
        clk <= 0;
        forever #(period/2) clk <= ~clk;
    end  // initial clock

    // test
    initial begin
        // 1. reset clears accumulator
        // sample_out should be 0 while reset is held, check different en/sample in value
		  // sd for signed decimal
        reset <= 1; en <= 0; sample_in <= 24'sd800;  @(posedge clk);
                    en <= 1; sample_in <= 24'sd800;  @(posedge clk);  // en=1 during reset, acc must stay 0
                    en <= 0; sample_in <= 24'sd0;    @(posedge clk);
        // expected: sample_out = 0

         // 2. when the buffer is not full
		  // acc increases linearly
        reset <= 0; en <= 1; sample_in <= 24'sd800; @(posedge clk);  // acc = 100
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 200
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 300
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 400
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 500
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 600
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 700
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 800, FIFO now full

          // 3. very steady
		  // now send 1600 instead. divided_in = 200,divided_out = 100
        // after 8 samples, it'll be filled with 200
                    en <= 1; sample_in <= 24'sd1600; @(posedge clk);  // acc = 900
                              sample_in <= 24'sd1600; @(posedge clk);  // acc = 1000
                              sample_in <= 24'sd1600; @(posedge clk);  // acc = 1100
                              sample_in <= 24'sd1600; @(posedge clk);  // acc = 1200
                              sample_in <= 24'sd1600; @(posedge clk);  // acc = 1300
                              sample_in <= 24'sd1600; @(posedge clk);  // acc = 1400
                              sample_in <= 24'sd1600; @(posedge clk);  // acc = 1500
                              sample_in <= 24'sd1600; @(posedge clk);  // acc = 1600
			// 4. negatives.
        // reset first, then send -800
        reset <= 1; en <= 0; sample_in <= 24'sd0;    @(posedge clk);
        reset <= 0; en <= 1; sample_in <= -24'sd800; @(posedge clk);  // acc = -100
                              sample_in <= -24'sd800; @(posedge clk);  // acc = -200
                              sample_in <= -24'sd800; @(posedge clk);  // acc = -300
                              sample_in <= -24'sd800; @(posedge clk);  // acc = -400
                              sample_in <= -24'sd800; @(posedge clk);  // acc = -500
                              sample_in <= -24'sd800; @(posedge clk);  // acc = -600
                              sample_in <= -24'sd800; @(posedge clk);  // acc = -700
                              sample_in <= -24'sd800; @(posedge clk);  // acc = -800

        // 5.noise cancellation
        reset <= 1; en <= 0; sample_in <= 24'sd0;    @(posedge clk);
        reset <= 0; en <= 1; sample_in <=  24'sd800; @(posedge clk);  // acc = 100
                              sample_in <= -24'sd800; @(posedge clk);  // acc = 0
                              sample_in <=  24'sd800; @(posedge clk);  // acc = 100
                              sample_in <= -24'sd800; @(posedge clk);  // acc = 0
                              sample_in <=  24'sd800; @(posedge clk);  // acc = 100
                              sample_in <= -24'sd800; @(posedge clk);  // acc = 0
                              sample_in <=  24'sd800; @(posedge clk);  // acc = 100
                              sample_in <= -24'sd800; @(posedge clk);  // acc = 0, FIFO full
                              sample_in <=  24'sd800; @(posedge clk);  // acc = 0 steady-state
                              sample_in <= -24'sd800; @(posedge clk);  // acc = 0
                              sample_in <=  24'sd800; @(posedge clk);  // acc = 0
                              sample_in <= -24'sd800; @(posedge clk);  // acc = 0
                              sample_in <=  24'sd800; @(posedge clk);  // acc = 0
                              sample_in <= -24'sd800; @(posedge clk);  // acc = 0
                              sample_in <=  24'sd800; @(posedge clk);  // acc = 0
                              sample_in <= -24'sd800; @(posedge clk);  // acc = 0

        // test reset again
        reset <= 1; en <= 0; sample_in <= 24'sd0;   @(posedge clk);
        reset <= 0; en <= 1; sample_in <= 24'sd800; repeat(8) @(posedge clk);  // fill: acc=800
        reset <= 1; en <= 0;                         @(posedge clk);
        reset <= 0; en <= 1; sample_in <= 24'sd800; @(posedge clk);  // acc = 100
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 200
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 300
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 400
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 500
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 600
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 700
                              sample_in <= 24'sd800; @(posedge clk);  // acc = 800

        // 7. test enable
        reset <= 1; en <= 0; sample_in <= 24'sd0;     @(posedge clk);
        reset <= 0; en <= 1; sample_in <= 24'sd800;   @(posedge clk);  // acc = 100
                    en <= 0; sample_in <= 24'sd99999;  @(posedge clk);  
                              sample_in <= 24'sd99999; @(posedge clk); 
                              sample_in <= 24'sd99999; @(posedge clk); 
                              sample_in <= 24'sd99999; @(posedge clk); 
                              sample_in <= 24'sd99999; @(posedge clk); 
                    en <= 1; sample_in <= 24'sd800;   @(posedge clk);  // acc = 200

        $stop;  // end simulation
    end  // initial
endmodule  // fir_filter_tb