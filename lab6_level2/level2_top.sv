module level2_top (
    input  logic clk, reset,
    input  logic btn_left, btn_right, btn_jump,
    input  logic [9:0] x,
    input  logic [8:0] y,
    output logic [7:0] r, g, b
);

    // -----------------------------------------------------------------------
    // Layout (all pixel coordinates, origin = top-left):
    //
    //   GROUND_Y = 210  (gray floor from y=210 downward)
    //
    //   Box:      starts at x=150, y=185  (sits on ground: 210 - 25 = 185)
    //   Elevator: x=250 (fixed), bounces between MIN_Y=50 and MAX_Y=185
    //
    //   Right-side shelf: x=560, y=80, 80px wide, 4px tall
    //     → sits just above the elevator's highest point (MIN_Y=50, elev_H=8
    //       means elev top = 50, player on elevator = 50-28 = 22, jump reaches
    //       the shelf at y=80)
    //
    //   Door:     x=580, y=40, 20px wide, 40px tall
    //     → positioned on the right wall above the shelf; only reachable by
    //       riding the elevator to the top and walking onto the shelf.
    // -----------------------------------------------------------------------

    // --- Shared dimensions (must match what's passed to each sub-module) ---
    localparam int P_W = 40, P_H = 42;
    localparam int B_W = 20, B_H = 25;
    localparam int E_W = 40, E_H = 8;
    localparam int GROUND_Y = 210;

    // Right-side shelf
    localparam int SHELF_X = 370, SHELF_Y = 80, SHELF_W = 80, SHELF_H = 4;

    // Door (drawn on top of the shelf, flush to right edge)
    localparam int DOOR_X = 430, DOOR_Y = 60, DOOR_W = 20, DOOR_H = 40;

    // -----------------------------------------------------------------------
    // Frame tick for physics updates (approx 60 Hz from 50 MHz clock)
    // -----------------------------------------------------------------------
    logic [19:0] frame_counter;
    logic frame_tick;

    always_ff @(posedge clk) begin
        if (reset) begin
            frame_counter <= 0;
            frame_tick    <= 0;
        end else begin
            if (frame_counter >= 20'd833333) begin
                frame_counter <= 0;
                frame_tick    <= 1'b1;
            end else begin
                frame_counter <= frame_counter + 1'b1;
                frame_tick    <= 1'b0;
            end
        end
    end

    // --- COORDINATE WIRES ---
    logic [9:0] p_x, b_x, e_x;
    logic [8:0] p_y, b_y, e_y;
    logic push_l, push_r;

    // --- PHYSICS MODULES ---
    player_update_pos2 #(
        .GROUND_Y(GROUND_Y), .SPEED(1), .JUMP_POWER(9),
        .P_W(P_W), .P_H(P_H),
        .B_W(B_W), .B_H(B_H),
        .E_W(E_W), .E_H(E_H),
        .S_W(SHELF_W), .S_H(SHELF_H),
        .SNAP_TOL(4)
    ) cat_brain (
        .clk, .reset, .update_en(frame_tick),
        .btn_left, .btn_right, .btn_jump,
        .box_x(b_x),      .box_y(b_y),
        .elevator_x(e_x), .elevator_y(e_y),
        .shelf_x(SHELF_X), .shelf_y(SHELF_Y),
        .player_x(p_x), .player_y(p_y),
        .push_left(push_l), .push_right(push_r)
    );

    box_update_pos #(
        .START_X(150), .START_Y(GROUND_Y - B_H), .SPEED(1)
    ) box_brain (
        .clk, .reset, .update_en(frame_tick),
        .push_left(push_l), .push_right(push_r),
        .box_x(b_x), .box_y(b_y)
    );

    elevator_update_pos #(
        .START_X(250), .MIN_Y(50), .MAX_Y(GROUND_Y - B_H), .SPEED(1)
    ) elev_brain (
        .clk, .reset, .update_en(frame_tick),
        .elevator_x(e_x), .elevator_y(e_y)
    );

    // --- DRAWING MODULES ---
    logic cat_on, box_on, elev_on;
    logic [7:0] cat_r, cat_g, cat_b;
    logic [7:0] box_r, box_g, box_b;
    logic [7:0] elev_r, elev_g, elev_b;

    lilcat_shape player_sprite (
        .clk, .x, .y,
        .pos_x(p_x), .pos_y(p_y),
        .pixel_on(cat_on), .r(cat_r), .g(cat_g), .b(cat_b)
    );

    box_shape #(.BOX_W(B_W), .BOX_H(B_H)) box_sprite (
        .x, .y, .pos_x(b_x), .pos_y(b_y),
        .pixel_on(box_on), .r(box_r), .g(box_g), .b(box_b)
    );

    elevator_shape #(.ELEVATOR_W(E_W), .ELEVATOR_H(E_H)) elev_sprite (
        .x, .y, .pos_x(e_x), .pos_y(e_y),
        .pixel_on(elev_on), .r(elev_r), .g(elev_g), .b(elev_b)
    );

    // Shelf and door are simple rectangles — no separate module needed
    logic shelf_on, door_on;
    assign shelf_on = (x >= SHELF_X) && (x < SHELF_X + SHELF_W) &&
                      (y >= SHELF_Y) && (y < SHELF_Y + SHELF_H);
    assign door_on  = (x >= DOOR_X)  && (x < DOOR_X  + DOOR_W)  &&
                      (y >= DOOR_Y)  && (y < DOOR_Y  + DOOR_H);

    // --- COLOR MULTIPLEXER (priority: cat > box > elevator > door > shelf > floor > bg) ---
    always_comb begin
        if (cat_on)
            {r, g, b} = {cat_r, cat_g, cat_b};
        else if (box_on)
            {r, g, b} = {box_r, box_g, box_b};
        else if (elev_on)
            {r, g, b} = {elev_r, elev_g, elev_b};
        else if (door_on)
            // Brown door with a bright yellow doorknob pixel band
            {r, g, b} = {8'h8B, 8'h45, 8'h13};
        else if (shelf_on)
            {r, g, b} = {8'h60, 8'h40, 8'h20}; // Dark brown shelf/ledge
        else if (y >= GROUND_Y)
            {r, g, b} = {8'h80, 8'h80, 8'h80}; // Gray floor
        else
            {r, g, b} = {8'hFF, 8'hFF, 8'hFF}; // White background
    end

endmodule