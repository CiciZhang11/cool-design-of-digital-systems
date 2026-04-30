// The testbench for part2.sv

`timescale 1ns/1ps

module part2_tb();

    // parameter
    // define module port connections
    logic CLOCK_50;
    logic CLOCK2_50;
    logic [0:0] KEY;

    wire AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT;
    wire FPGA_I2C_SCLK, FPGA_I2C_SDAT;

    // expected tracking
    int expected_addr;

    // instantiate module
    part2 #(.ROM_SIZE(48000)) uut (
        .CLOCK_50(CLOCK_50),
        .CLOCK2_50(CLOCK2_50),
        .KEY(KEY),
        .FPGA_I2C_SCLK(FPGA_I2C_SCLK),
        .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
        .AUD_XCK(AUD_XCK),
        .AUD_DACLRCK(AUD_DACLRCK),
        .AUD_ADCLRCK(AUD_ADCLRCK),
        .AUD_BCLK(AUD_BCLK),
        .AUD_ADCDAT(1'b0), // Input
        .AUD_DACDAT(AUD_DACDAT)
    );

    // create simulated clock
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        CLOCK2_50 = 0;
        forever #10 CLOCK2_50 = ~CLOCK2_50;
    end

    // define test inputs
    initial begin
        // Reset sequence
        KEY[0] = 1'b0; #100;   // reset
        KEY[0] = 1'b1; #100;   // Release reset

        expected_addr = 0;

        // write_ready 
        repeat (100) begin
            @(posedge CLOCK_50);
            force uut.write_ready = 1'b1; @(posedge CLOCK_50); // trigger read enable
            release uut.write_ready; // return to idle

            expected_addr = (expected_addr + 1) % 48000;

            repeat (2) @(posedge CLOCK_50);
        end

        // sync expected with DUT before checking
        expected_addr = uut.rom_addr;

        // test first 20 elements and print expected values
        repeat (20) begin
            @(posedge CLOCK_50);
            force uut.write_ready = 1'b1; @(posedge CLOCK_50);
            release uut.write_ready;

            expected_addr = (expected_addr + 1) % 48000;

            $display("FIRST20: addr=%0d (exp=%0d) data=%h (exp=%h)",
                uut.rom_addr, expected_addr,
                uut.rom_data, uut.rom_data);
        end
        
        // test last 20 elements and print expected values
        force uut.rom_addr = 16'd47980; // move near end safely
        #1;
        release uut.rom_addr;    
        expected_addr = 47980;

        repeat (20) begin
            @(posedge CLOCK_50);
            force uut.write_ready = 1'b1; @(posedge CLOCK_50);
            release uut.write_ready;

            expected_addr = (expected_addr + 1) % 48000;

            $display("LAST20: addr=%0d (exp=%0d) data=%h (exp=%h)",
                uut.rom_addr, expected_addr,
                uut.rom_data, uut.rom_data);
        end

        // test wrap around behavior, test 10 elements
        force uut.rom_addr = 16'd47999;
        #1;
        release uut.rom_addr; 
        expected_addr = 47999;

        repeat (10) begin
            @(posedge CLOCK_50);
            force uut.write_ready = 1'b1;
            @(posedge CLOCK_50);
            release uut.write_ready;

            expected_addr = (expected_addr + 1) % 48000;

            $display("WRAP: addr=%0d (exp=%0d) data=%h (exp=%h)",
                uut.rom_addr, expected_addr,
                uut.rom_data, uut.rom_data);
        end

        $stop;
    end

endmodule // end part2_tb
