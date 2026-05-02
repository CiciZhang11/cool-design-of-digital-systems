// Task 1 – Passing Music Through the FPGA

module task1 (
    input  logic [23:0] readdata_left,
    input  logic [23:0] readdata_right,
    output logic [23:0] audio_out
);

    assign audio_out = readdata_left;

endmodule // end module task 1