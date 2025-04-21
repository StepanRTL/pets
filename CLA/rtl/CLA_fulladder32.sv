module CLA_fulladder32(
    input  logic        clk_i,
    input  logic        aresetn_i,
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    input  logic        carry_i,
    output logic [31:0] sum_o,
    output logic        carry_o
);

  logic [8 :0] c;
  logic [31:0] a_ff;
  logic [31:0] b_ff;
  logic        carry_ff;
  logic [31:0] sum_ff;

  always_ff @(posedge clk_i or negedge aresetn_i)
    if (~aresetn_i)
      a_ff <= 32'b0;
    else
      a_ff <= a_i;

  always_ff @(posedge clk_i or negedge aresetn_i)
    if (~aresetn_i)
      b_ff <= 32'b0;
    else
      b_ff <= b_i;

  always_ff @(posedge clk_i or negedge aresetn_i)
    if (~aresetn_i)
      carry_ff <= 32'b0;
    else
      carry_ff <= carry_i;

  assign c[0] = carry_ff;
  generate
    genvar i;
    for (i = 0; i < 8; i++) begin
      CLA_fulladder4 inst
      (
        .a_i  (a_i[4 * i +: 4]   ),
        .b_i  (b_i[4 * i +: 4]   ),
        .c_i  (c[i]              ),
        .sum_o(sum_ff[4 * i +: 4]),
        .c_o  (c[i + 1]          )
      );
    end
  endgenerate

  always_ff @(posedge clk_i or negedge aresetn_i)
    if (~aresetn_i)
      carry_o <= 1'b0;
    else
      carry_o <= c[8];

  always_ff @(posedge clk_i or negedge aresetn_i)
    if (~aresetn_i)
      sum_o <= 1'b0;
    else
      sum_o <= sum_ff;  

endmodule