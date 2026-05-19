`timescale 1ns / 1ps

module line_drawer_tb();

    // --- Signals ---
    logic clk;
    logic reset;
    logic [10:0] x0, y0, x1, y1;
    logic [10:0] x, y;
    logic done;

    // --- Module Instantiation ---
    line_drawer dut (
        .clk(clk),
        .reset(reset),
        .x0(x0),
        .y0(y0),
        .x1(x1),
        .y1(y1),
        .x(x),
        .y(y),
        .done(done)
    );

    // --- Clock Generation (50 MHz = 20ns period) ---
    always #10 clk = ~clk;

    // --- Task to automate drawing lines ---
    task draw_line(
        input string case_name, 
        input [10:0] start_x, 
        input [10:0] start_y, 
        input [10:0] end_x, 
        input [10:0] end_y
    );
        begin
            $display("--------------------------------------------------");
            $display("STARTING: %s", case_name);
            $display("From (x0,y0) = (%0d, %0d) to (x1,y1) = (%0d, %0d)", start_x, start_y, end_x, end_y);
            
            // Set inputs
            x0 = start_x;
            y0 = start_y;
            x1 = end_x;
            y1 = end_y;
            
            // Trigger Reset
            reset = 1;
            @(posedge clk);
            reset = 0;
            
            // Wait for the line drawer to assert 'done'
            // A timeout is added just in case the FSM gets stuck, so the simulation doesn't hang forever
            fork
                begin
                    wait(done == 1'b1);
                    $display("SUCCESS: %s completed.", case_name);
                end
                begin
                    repeat(1000) @(posedge clk);
                    $error("TIMEOUT: %s took too long. Check FSM or done logic.", case_name);
                end
            join_any
            disable fork; // Kill the timeout if the wait() finishes first
            
            @(posedge clk); // Give one extra clock cycle before the next test
        end
    endtask

    // --- Main Simulation Block ---
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        x0 = 0; y0 = 0; x1 = 0; y1 = 0;
        
        // Wait a few clock cycles before starting
        repeat(5) @(posedge clk);

        /* * The 8 Required Test Cases
         * Assuming a standard monitor coordinate system where (0,0) is top-left.
         * Increasing X moves Right. Increasing Y moves Down.
         */

        // 1. Right-Down (Gradual: X changes more than Y)
        draw_line("Right-Down Gradual", 10, 10, 100, 30);
        
        // 2. Right-Down (Steep: Y changes more than X)
        draw_line("Right-Down Steep", 10, 10, 30, 100);

        // 3. Right-Up (Gradual)
        draw_line("Right-Up Gradual", 10, 100, 100, 80);

        // 4. Right-Up (Steep)
        draw_line("Right-Up Steep", 10, 100, 30, 10);

        // 5. Left-Down (Gradual)
        draw_line("Left-Down Gradual", 100, 10, 10, 30);

        // 6. Left-Down (Steep)
        draw_line("Left-Down Steep", 100, 10, 80, 100);

        // 7. Left-Up (Gradual)
        draw_line("Left-Up Gradual", 100, 100, 10, 80);

        // 8. Left-Up (Steep)
        draw_line("Left-Up Steep", 100, 100, 80, 10);

        $display("--------------------------------------------------");
        $display("ALL TESTS COMPLETED.");
        $stop; // End simulation
    end

    // --- Optional: Monitor outputs to console ---
    // Uncomment this if you want to see every single pixel printed to the transcript
   
    always_ff @(posedge clk) begin
        if (!reset && !done) begin
            $display("Pixel drawn at x = %0d, y = %0d", x, y);
        end
    end
 

endmodule