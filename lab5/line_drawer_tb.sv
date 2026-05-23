// This is the testbench for line drawer, and here, we tested 8 cases.:
// for steep(abs(y1-y0)>abs(x1-x0)):
// 1. draw left-up
// 2. right-up
// 3. left-down
// 4. right-down
// for non steep(!steep):
// 5. draw left-up
// 6. right-up
// 7. left-down
// 8. right-down
// we also test additional conditions:
// 9. x0=x1, y0!=y1
// 10. x0!=x1, y0=y1
// 11. x0=x1, y0=y1
`timescale 1ns/1ps
module line_drawer_tb();
    logic clk, reset;
    logic [10:0] x0, y0, x1, y1;
    logic [10:0] x, y;
    logic done;

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
	// clock
parameter period = 100;
	initial begin
		clk <= 0;
		forever #(period/2) clk <= ~clk;
	end  // initial clock


    
    always_ff @(posedge clk) begin
        // Print internal setup variables the moment we finish swapping
        if (dut.ps == dut.S_CALC && dut.ns == dut.S_DRAW) begin
            $display("is_steep=%b swapped points: (%0d, %0d) to (%0d, %0d)", 
                     dut.is_steep, dut.x0r, dut.y0r, dut.x1r, dut.y1r);
        end // end if
        
        // current process
        if (dut.ps == dut.S_DRAW && !done) begin
            $display("outputs: (x=%0d, y=%0d) internal: cx=%0d, cy=%0d, error=%0d", 
                     x, y, dut.cx, dut.cy, dut.error);
        end // end if
    end
	//test cases
    initial begin
        reset = 1;
        x0 = 0; y0 = 0; x1 = 0; y1 = 0;
        repeat(2) @(posedge clk);


			// test steep: abs(y1-y0)>abs(x1-x0)
        $display("\n\n1. Steep: Left-Up");
        x0 = 13; y0 = 18; x1 = 10; y1 = 10;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        $display("\n\n2. Steep: Right-Up");
        x0 = 10; y0 = 18; x1 = 13; y1 = 10;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        $display("\n\n3. Steep: Left-Down");
        x0 = 13; y0 = 10; x1 = 10; y1 = 18;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        $display("\n\n4. Steep: Right-Down");
        x0 = 10; y0 = 10; x1 = 13; y1 = 18;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);
			//non steep

        $display("5. Non steep: Left-Up");
        x0 = 18; y0 = 13; x1 = 10; y1 = 10;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        $display("\n\n 6. Non steep: Right-Up");
        x0 = 10; y0 = 13; x1 = 18; y1 = 10;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        $display("\n\n 7. Non steep: Left-Down");
        x0 = 18; y0 = 10; x1 = 10; y1 = 13;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        $display("\n\n 8. Non steep: Right-Down");
        x0 = 10; y0 = 10; x1 = 18; y1 = 13;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        //edge cases
        $display("\n\n 9. Vertical (x0=x1, y0!=y1) ");
        x0 = 15; y0 = 10; x1 = 15; y1 = 20;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        $display("\n\n 10. Horizontal (x0!=x1, y0=y1)");
        x0 = 10; y0 = 15; x1 = 20; y1 = 15;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        $display("\n\n 11. Single Point (x0=x1, y0=y1)");
        x0 = 15; y0 = 15; x1 = 15; y1 = 15;
        reset = 1; @(posedge clk); reset = 0;
		  wait(done == 0);
        wait(done == 1); @(posedge clk);

        // End Simulation
        $display("\n\n end simulation");
        $stop;
    end // initial begin

endmodule // end module