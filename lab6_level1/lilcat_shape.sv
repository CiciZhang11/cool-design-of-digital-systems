// lilcat_shape.sv
// draws lilcat.mif into the framebuffer
// this is a sprite drawer not a line drawer shape
// player_x/player_y are the top-left corner
module lilcat_shape #(
    parameter int SPRITE_W  = 88,
    parameter int SPRITE_H  = 93,
    parameter int DISPLAY_W = 44,
    parameter int DISPLAY_H = 47
)(
    input  logic        clk,
    input  logic        reset,
    input  logic        start,

    input  logic [9:0]  player_x,
    input  logic [8:0]  player_y,

    output logic        pixel_write,
    output logic [10:0] write_x,
    output logic [10:0] write_y,
    output logic        pixel_color,

    output logic        done
);

    typedef enum logic [1:0] {
        S_IDLE,
        S_READ,
        S_DRAW,
        S_DONE
    } state_t;

    state_t state;

    logic [9:0] draw_col;
    logic [8:0] draw_row;

    logic [6:0] rom_row;
    logic [6:0] rom_col;
    logic [87:0] rom_data;

    logic [10:0] write_x_d;
    logic [10:0] write_y_d;
    logic [6:0]  rom_col_d;

    // Scale display coordinate to MIF coordinate
    // 44x47 display maps to 88x93 sprite
    assign rom_row = (draw_row * SPRITE_H) / DISPLAY_H;
    assign rom_col = (draw_col * SPRITE_W) / DISPLAY_W;

    lilcat_rom lilcat_rom_inst (
        .address (rom_row),
        .clock   (clk),
        .q       (rom_data)
    );

    always_ff @(posedge clk) begin
        if (reset) begin
            state       <= S_IDLE;
            draw_col    <= 10'd0;
            draw_row    <= 9'd0;

            write_x_d   <= 11'd0;
            write_y_d   <= 11'd0;
            rom_col_d   <= 7'd0;

            pixel_write <= 1'b0;
            write_x     <= 11'd0;
            write_y     <= 11'd0;
            pixel_color <= 1'b0;
            done        <= 1'b0;
        end // end if
        else begin
            pixel_write <= 1'b0;
            pixel_color <= 1'b1;
            done        <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (start) begin
                        draw_col <= 10'd0;
                        draw_row <= 9'd0;
                        state    <= S_READ;
                    end // end if
                end // end begin

                // Save screen position and ROM column
                // This gives the ROM address one clock cycle to update
                S_READ: begin
                    write_x_d <= {1'b0, player_x} + draw_col;
                    write_y_d <= {2'b00, player_y} + draw_row;
                    rom_col_d <= rom_col;
                    state     <= S_DRAW;
                end // end begin

                S_DRAW: begin
                    // If the image appears mirrored, change this to: rom_data[rom_col_d]
                    if (rom_data[SPRITE_W - 1 - rom_col_d]) begin
                        pixel_write <= 1'b1;
                        write_x     <= write_x_d;
                        write_y     <= write_y_d;
                        pixel_color <= 1'b1;
                    end // end if

                    if (draw_col == DISPLAY_W - 1) begin
                        draw_col <= 10'd0;

                        if (draw_row == DISPLAY_H - 1) begin
                            draw_row <= 9'd0;
                            state    <= S_DONE;
                        end // end if
                        else begin
                            draw_row <= draw_row + 9'd1;
                            state    <= S_READ;
                        end // end else
                    end // end if
                    else begin
                        draw_col <= draw_col + 10'd1;
                        state    <= S_READ;
                    end // end else
                end // end begin

                S_DONE: begin
                    done  <= 1'b1;
                    state <= S_IDLE;
                end // end begin

                default: begin
                    state <= S_IDLE;
                end // end case item
            endcase // end case
        end // end else
    end // end always_ff

endmodule // end module lilcat_shape
