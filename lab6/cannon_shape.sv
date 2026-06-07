// cannon_shape.sv
// static level 1 shape
// draws floor and cannon
module cannon_shape #(
    parameter int FLOOR_Y = 360
)(
    input  logic [3:0] line_num,

    output logic [10:0] x0,
    output logic [10:0] y0,
    output logic [10:0] x1,
    output logic [10:0] y1
);

    // Floor
    localparam logic [10:0] FLOOR_X0 = 11'd40;
    localparam logic [10:0] FLOOR_X1 = 11'd620;
    localparam logic [10:0] FLOOR_Y_11 = FLOOR_Y;

    // Square body on the right
    localparam logic [10:0] SQ_L = 11'd560;
    localparam logic [10:0] SQ_R = 11'd610;
    localparam logic [10:0] SQ_T = 11'd300;
    localparam logic [10:0] SQ_B = 11'd350;

    // Trapezoid on the left
    // Right side connects to the square's left side
    localparam logic [10:0] TR_L  = 11'd500;
    localparam logic [10:0] TR_LT = 11'd315;
    localparam logic [10:0] TR_LB = 11'd335;

    always_comb begin
        x0 = 11'd0;
        y0 = 11'd0;
        x1 = 11'd0;
        y1 = 11'd0;

        case (line_num)
            // 0: floor
            4'd0: begin
                x0 = FLOOR_X0;
                y0 = FLOOR_Y_11;
                x1 = FLOOR_X1;
                y1 = FLOOR_Y_11;
            end // end case item

            // 1-4: square body
            4'd1: begin x0 = SQ_L; y0 = SQ_T; x1 = SQ_R; y1 = SQ_T; end
            4'd2: begin x0 = SQ_R; y0 = SQ_T; x1 = SQ_R; y1 = SQ_B; end
            4'd3: begin x0 = SQ_R; y0 = SQ_B; x1 = SQ_L; y1 = SQ_B; end
            4'd4: begin x0 = SQ_L; y0 = SQ_B; x1 = SQ_L; y1 = SQ_T; end

            // 5-7: trapezoid
            4'd5: begin x0 = TR_L; y0 = TR_LT; x1 = SQ_L; y1 = SQ_T; end
            4'd6: begin x0 = SQ_L; y0 = SQ_B; x1 = TR_L; y1 = TR_LB; end
            4'd7: begin x0 = TR_L; y0 = TR_LB; x1 = TR_L; y1 = TR_LT; end

            default: begin
                x0 = 11'd0;
                y0 = 11'd0;
                x1 = 11'd0;
                y1 = 11'd0;
            end // end case item
        endcase // end case
    end // end always_comb

endmodule // end module cannon_shape
