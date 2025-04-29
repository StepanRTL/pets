module mult_cordic # (parameter WIDTH = 8) (
  input  logic                   clk_i,
  input  logic                   aresetn_i,
  input  logic [WIDTH - 1:0]     a_i,
  input  logic [WIDTH - 1:0]     b_i,
  output logic [2 * WIDTH - 1:0] result_o
);

  logic [2 * WIDTH - 1:0] x [WIDTH - 1:0];
  logic [2 * WIDTH - 1:0] y [WIDTH - 1:0];
  logic [2 * WIDTH - 1:0] z [WIDTH - 1:0];

  generate
    genvar i;
    for (i = 0; i < WIDTH - 1; i++) begin
      always_ff @(posedge clk_i or negedge aresetn_i) begin
        if (~aresetn_i) begin
          x[i] <= {(2 * WIDTH){1'b0}};
          y[i] <= {(2 * WIDTH){1'b0}};
          z[i] <= {(2 * WIDTH){1'b0}};
        end
        else  begin
          x[i] <= a_i;
          y[i] <= {WIDTH{1'b0}};
          z[i] <= b_i;
        end
        else begin
          x[i] <= x[i - 1];
          if (z[i - 1][WIDTH - 1]) begin
            y[i] <= y[i - 1] - (x[i - 1] >>> i);
            z[i + 1] <= z[i] + (1 >> i);
          end
          else begin
            y[i + 1] <= y[i] + (x[i] >>> i);
            z[i + 1] <= z[i] - (1 >> i);
          end
        end
      end
    end
  endgenerate

  assign result_o = y[WIDTH - 1];
endmodule

