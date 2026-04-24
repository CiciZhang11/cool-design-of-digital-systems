/* Arbitrary ASM chart implementation to examine output timings */
module hw3p3 (clk, reset, X, Ya, Yb, Yc, Z1, Z2);
  
  // for you to implement
  input  logic clk, reset, X;
  output logic Ya, Yb, Yc;
  output logic Z1, Z2;

  enum logic [1:0] {S_Ya, S_Yb, S_Yc} ps, ns;

  // state register
  always_ff @(posedge clk) begin
    if (reset)
      ps <= S_Ya;
    else
      ps <= ns;
  end

  // next-state logic
  always_comb begin
    ns = ps;

    case (ps)
      S_Ya: begin
        if (X)
          ns = S_Yb;
        else
          ns = S_Ya;
      end

      S_Yb: begin
        if (X)
          ns = S_Yc;
        else
          ns = S_Ya;
      end

      S_Yc: begin
        if (X)
          ns = S_Yc;
        else
          ns = S_Ya;
      end

      default: ns = S_Ya;
    endcase
  end

  // output logic
  always_comb begin
    Ya = 1'b0;
    Yb = 1'b0;
    Yc = 1'b0;
    Z1 = 1'b0;
    Z2 = 1'b0;

    case (ps)
      S_Ya: begin
        Ya = 1'b1;
      end

      S_Yb: begin
        Yb = 1'b1;
      end

      S_Yc: begin
        Yc = 1'b1;

        if (X)
          Z2 = 1'b1;
        else
          Z1 = 1'b1;
      end
    endcase
  end

endmodule  // hw3p3