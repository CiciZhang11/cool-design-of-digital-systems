// wall_shape.sv
// line based three layer wall
// wall_layers_left decides how many layers show
module wall_shape #(
    parameter int WALL_X       = 60,
    parameter int WALL_Y       = 280,
    parameter int WALL_LAYER_W = 24,
    parameter int WALL_H       = 80
)(
    input  logic [1:0] wall_layers_left,
    input  logic [3:0] line_idx,

    output logic [10:0] x0,
    output logic [10:0] y0,
    output logic [10:0] x1,
    output logic [10:0] y1,
    output logic        line_valid
);

    localparam logic [10:0] WX = WALL_X;
    localparam logic [10:0] WY = WALL_Y;
    localparam logic [10:0] LW = WALL_LAYER_W;
    localparam logic [10:0] WH = WALL_H;

    logic [1:0] layer;
    logic [1:0] wall_edge;
    logic [10:0] lx;

    always_comb begin
        x0 = 11'd0;
        y0 = 11'd0;
        x1 = 11'd0;
        y1 = 11'd0;
        line_valid = 1'b0;

        layer     = line_idx[3:2];
        wall_edge = line_idx[1:0];
        lx        = WX + ({9'd0, layer} * LW);

        // line_idx 0-3: layer 0
        // line_idx 4-7: layer 1
        // line_idx 8-11: layer 2
        if ((line_idx < 4'd12) && (layer < wall_layers_left)) begin
            line_valid = 1'b1;

            case (wall_edge)
                2'd0: begin x0 = lx;      y0 = WY;      x1 = lx + LW; y1 = WY;      end
                2'd1: begin x0 = lx + LW; y0 = WY;      x1 = lx + LW; y1 = WY + WH; end
                2'd2: begin x0 = lx + LW; y0 = WY + WH; x1 = lx;      y1 = WY + WH; end
                2'd3: begin x0 = lx;      y0 = WY + WH; x1 = lx;      y1 = WY;      end
                default: begin x0 = lx;   y0 = WY;      x1 = lx + LW; y1 = WY;      end
            endcase // end case
        end // end if
    end // end always_comb

endmodule // end module wall_shape
