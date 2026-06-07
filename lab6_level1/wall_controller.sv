// wall_controller.sv
// one bullet hit removes one wall layer
module wall_controller #(
    parameter int START_LAYERS = 3
)(
    input  logic clk,
    input  logic reset,
    input  logic update_en,
    input  logic enable,
    input  logic hit_wall,

    output logic [1:0] wall_layers_left,
    output logic       level_clear
);

    localparam logic [1:0] START_LAYERS_2 = START_LAYERS;

    assign level_clear = (wall_layers_left == 2'd0);

    always_ff @(posedge clk) begin
        if (reset) begin
            wall_layers_left <= START_LAYERS_2;
        end // end if
        else if (enable && update_en) begin
            if (hit_wall && (wall_layers_left != 2'd0)) begin
                wall_layers_left <= wall_layers_left - 2'd1;
            end // end if
        end // end else if
    end // end always_ff

endmodule // end module wall_controller
