module pg_node (
  input  logic p_left_old_i,
  input  logic g_left_old_i,
  input  logic p_right_old_i,
  input  logic g_right_old_i,
  output logic p_new_o,
  output logic g_new_o
);

  assign p_new_o = p_left_old_i & p_right_old_i;
  assign g_new_o = g_right_old_i | g_left_old_i & p_right_old_i;

endmodule
