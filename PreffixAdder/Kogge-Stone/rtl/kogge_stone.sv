module kogge_stone #(parameter DATA_WIDTH = 8) (
  input  logic [DATA_WIDTH - 1:0] a_i,
  input  logic [DATA_WIDTH - 1:0] b_i,
  input  logic                    c_i,
  output logic                    c_o,
  output logic [DATA_WIDTH - 1:0] sum_o
);

  localparam STAGES = $clog2(DATA_WIDTH);

  logic [DATA_WIDTH - 1:0] g_value [STAGES : 0];
  logic [DATA_WIDTH - 1:0] p_value [STAGES : 0];
  logic [DATA_WIDTH : 0]   carry;

  assign g_value[0] = a_i & b_i;
  assign p_value[0] = a_i | b_i;

  generate
    genvar i;
    genvar j;
    for (i = 1; i <= STAGES; i++) begin
      for (j = 0; j < DATA_WIDTH; j++) begin
        if (j >= 1 << (i - 1)) begin
          pg_node node_inst
          (
            .p_left_old_i (p_value[i - 1][j - (1 << (i - 1))]),
            .g_left_old_i (g_value[i - 1][j - (1 << (i - 1))]),
            .p_right_old_i(p_value[i - 1][j]                 ),
            .g_right_old_i(g_value[i - 1][j]                 ),
            .p_new_o      (p_value[i][j]                     ),
            .g_new_o      (g_value[i][j]                     )
          );
        end
        else begin
          assign p_value[i][j] = p_value[i-1][j];
          assign g_value[i][j] = g_value[i-1][j];
        end
      end
    end
  endgenerate

  assign carry[0] = c_i;

  generate
    for (genvar k = 0; k < DATA_WIDTH; k++) begin
      assign carry[k+1] = g_value[STAGES][k] | (p_value[STAGES][k] & carry[k]);
    end
  endgenerate

  assign c_o = carry[DATA_WIDTH];

  generate
    genvar m;
    for (m = 0; m < DATA_WIDTH; m++) begin
      fulladder add_inst
      (
        .a_i     (a_i[m]  ),
        .b_i     (b_i[m]  ),
        .carry_i (carry[m]),
        .sum_o   (sum_o[m]),
        .carry_o (        )
      );
    end
  endgenerate
endmodule
