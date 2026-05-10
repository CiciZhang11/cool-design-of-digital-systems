// This is DE1, top level that muxes task1 and task2 outputs using
// SW[9]. when SW[9] = 0, we present task1, where LEDR[9]=done, HEX0=count.
// When SW[9] = 0, we present task2, where LEDR[9]=done, LEDR[0]=found, and
// HEX1:HEX0 is location.
module DE1_SoC (
    input  logic CLOCK_50,
    input  logic [9:0] SW,
    input  logic [3:0] KEY,
    output logic [9:0] LEDR,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1
);

    logic [9:0] ledr_t1;
    logic [6:0] hex0_t1;

    task1 u_task1 (
        .CLOCK_50 (CLOCK_50),
        .SW (SW),        // SW[7:0] used
        .KEY (KEY),
        .LEDR (ledr_t1), // LEDR[9]=done
        .HEX0 (hex0_t1)
    );

    logic [9:0] ledr_t2;
    logic [6:0] hex0_t2;
    logic [6:0] hex1_t2;

    task2 u_task2 (
        .CLOCK_50 (CLOCK_50),
        .SW (SW),        // SW[7:0] used
        .KEY (KEY),
        .LEDR (ledr_t2),// LEDR[9]=done, LEDR[0]=found
        .HEX0 (hex0_t2),
        .HEX1 (hex1_t2)
    );

    always_comb begin
        if (SW[9]) begin
            // task2: binary search
            LEDR = ledr_t2;
            HEX0 = hex0_t2;
            HEX1 = hex1_t2;
        end else begin
            // task1: popcount
            LEDR = ledr_t1;
            HEX0 = hex0_t1;
            HEX1 = 7'b1111111; 
        end //else
    end //always_comb

endmodule // DE1_SoC