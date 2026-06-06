// LEVEL 2 door shape
// This module is used to draw the shape of the door in Level 2
// It outputs x0, y0, x1, y1 to the line_drawer
// The door is drawn at the top-right corner of the screen

module door_shape (
    input  logic [3:0] line_num,

    output logic [9:0] x0,
    output logic [8:0] y0,
    output logic [9:0] x1,
    output logic [8:0] y1
);

    // door position
    localparam logic [9:0] DOOR_LEFT_X   = 10'd500;
    localparam logic [9:0] DOOR_RIGHT_X  = 10'd580;
    localparam logic [9:0] ROOF_LEFT_X   = 10'd515;
    localparam logic [9:0] ROOF_RIGHT_X  = 10'd565;

    localparam logic [8:0] ROOF_Y        = 9'd80;
    localparam logic [8:0] WALL_TOP_Y    = 9'd120;
    localparam logic [8:0] FLOOR_Y       = 9'd210;

    // long floor line
    localparam logic [9:0] FLOOR_LEFT_X  = 10'd300;
    localparam logic [9:0] FLOOR_RIGHT_X = 10'd630;

    // doorknob square
    localparam logic [9:0] KNOB_LEFT_X   = 10'd520;
    localparam logic [9:0] KNOB_RIGHT_X  = 10'd530;
    localparam logic [8:0] KNOB_TOP_Y    = 9'd150;
    localparam logic [8:0] KNOB_BOT_Y    = 9'd160;

    always_comb begin
        x0 = 10'd0;
        y0 = 9'd0;
        x1 = 10'd0;
        y1 = 9'd0;

        case (line_num)
            // left vertical wall
            4'd0: begin
                x0 = DOOR_LEFT_X;
                y0 = WALL_TOP_Y;
                x1 = DOOR_LEFT_X;
                y1 = FLOOR_Y;
            end

            // right vertical wall
            4'd1: begin
                x0 = DOOR_RIGHT_X;
                y0 = WALL_TOP_Y;
                x1 = DOOR_RIGHT_X;
                y1 = FLOOR_Y;
            end

            // roof left slope
            4'd2: begin
                x0 = DOOR_LEFT_X;
                y0 = WALL_TOP_Y;
                x1 = ROOF_LEFT_X;
                y1 = ROOF_Y;
            end

            // roof top
            4'd3: begin
                x0 = ROOF_LEFT_X;
                y0 = ROOF_Y;
                x1 = ROOF_RIGHT_X;
                y1 = ROOF_Y;
            end

            // roof right slope
            4'd4: begin
                x0 = ROOF_RIGHT_X;
                y0 = ROOF_Y;
                x1 = DOOR_RIGHT_X;
                y1 = WALL_TOP_Y;
            end

            // long floor line
            4'd5: begin
                x0 = FLOOR_LEFT_X;
                y0 = FLOOR_Y;
                x1 = FLOOR_RIGHT_X;
                y1 = FLOOR_Y;
            end

            // doorknob square left side
            4'd6: begin
                x0 = KNOB_LEFT_X;
                y0 = KNOB_TOP_Y;
                x1 = KNOB_LEFT_X;
                y1 = KNOB_BOT_Y;
            end

            // doorknob square right side
            4'd7: begin
                x0 = KNOB_RIGHT_X;
                y0 = KNOB_TOP_Y;
                x1 = KNOB_RIGHT_X;
                y1 = KNOB_BOT_Y;
            end

            // doorknob square top
            4'd8: begin
                x0 = KNOB_LEFT_X;
                y0 = KNOB_TOP_Y;
                x1 = KNOB_RIGHT_X;
                y1 = KNOB_TOP_Y;
            end

            // doorknob square bottom
            4'd9: begin
                x0 = KNOB_LEFT_X;
                y0 = KNOB_BOT_Y;
                x1 = KNOB_RIGHT_X;
                y1 = KNOB_BOT_Y;
            end

            default: begin
                x0 = 10'd0;
                y0 = 9'd0;
                x1 = 10'd0;
                y1 = 9'd0;
            end
        endcase
    end

endmodule // END module door_shape