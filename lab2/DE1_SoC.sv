/* Top-level module for EE 371 Lab 2: Memory Blocks

Instantiates: Task 2 memory, Task 3 memory, seg7 displays
*/


module DE1_SoC #(parameter MAX_COUNT = 26'd49_999_999)(
    input  logic CLOCK_50, // for Task 3 module
    input  logic [9:0]  SW,
    input  logic [3:0]  KEY,
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output logic [9:0]  LEDR
);

    // User Input module: used to handle metastability
	 logic reset, key0;
	 user_input user3 (     
    .clk(CLOCK_50),
    .reset(1'b0),
    .key(~KEY[3]),
    .out(reset)
	 );
	 // Synchronize and edge-detect KEY0
	 user_input user0 (
    .clk(CLOCK_50),
    .reset(1'b0),     
    .key(~KEY[0]),
    .out(key0)
	 );

    // Basic
	 // Input signals:
    logic wren;
	 logic [2:0] data;
	 assign wren = SW[0];   // correct // SW0 --> Write
    assign data  = SW[3:1]; // SW3-S1 --> DataIn
	 
	 // Task 2 signals
    logic [4:0] address;
    logic [2:0] dout;
	 assign address = SW[8:4]; // Use SW8-SW4 to specify address
    
	 
	 // Task 3 signals
    logic [4:0] addr_w, addr_r;
    logic [2:0] dout_r;
	 assign addr_w = SW[8:4]; // SW[8:4] --> write address
	 
	 // Instantiate module task2
    task2 mem_t2 (
        .clk(~key0), // KEY[0] --> key0 --> Clock input
        .address(address),
        .data(data),
        .wren(wren),
        .dout(dout)
    );    
	 
	 // Instantiate module task3
    task3 mem_t3 (
        .clk(CLOCK_50), // use CLOCK_50 to synchtonize the system
        .data(data),
        .addr_r(addr_r),
        .addr_w(addr_w),
        .wren(wren),
        .dout_r(dout_r)
    );

	 
    // Counter
	 // cycle through the read addresses
    logic [25:0] count; // 2^26

always_ff @(posedge CLOCK_50) begin
    if (reset) begin
        count  <= 26'd0;
        addr_r <= 5'd0;
    end else begin
        // Replace the hardcoded number with the parameter!
        if (count == MAX_COUNT) begin
            count  <= 26'd0;
            addr_r <= addr_r + 5'd1;
        end else begin
            count <= count + 26'd1;
        end
    end
end

    // SW9: toggle between Task2 and Task3
    logic [2:0] data_out;
	 logic [4:0] disp_addr_w, disp_addr_r; // display addr_w and addr_r

    always_comb begin
        if (SW[9] == 1'b0) begin // SW9 = 0 --> Task 2
            data_out = dout;
				if (wren) begin
				    disp_addr_w = address;
					 disp_addr_r = 5'd0;
			   end
				else begin
				    disp_addr_w = 5'd0;
					 disp_addr_r = address;
				end
        end else begin // SW9 = 1 --> Task 3
            data_out    = dout_r;
				disp_addr_w = addr_w;
				disp_addr_r = addr_r; 
        end
    end

    // 7-segment displays
	 // Display the write address on HEX5-HEX4
	 seg7 h5 (.hex({3'b000, disp_addr_w[4]}),.leds(HEX5));
	 seg7 h4 (.hex(disp_addr_w[3:0]),        .leds(HEX4));
	 
	 // Display the write data on HEX1
	 seg7 h1 (.hex({1'b0, data}),  .leds(HEX1));
	 
	 // Display the read address on HEX3-2
	 seg7 h3 (.hex({3'b000, disp_addr_r[4]}), .leds(HEX3));
	 seg7 h2 (.hex(disp_addr_r[3:0]),         .leds(HEX2));
	 
	 // Display the 3+bit word content on HEX0
    seg7 h0 (.hex({1'b0, data_out}),      .leds(HEX0));

    // LEDs - SHOW Switches
    assign LEDR = SW;

endmodule