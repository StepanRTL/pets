module CLA_fulladder4 (
  input  logic [3:0] a_i,
  input  logic [3:0] b_i,
  input  logic       c_i,
  output logic [3:0] sum_o,
  output logic       c_o
);

  logic [3:0] generate_func;
  logic [3:0] propagate_func;
  logic [3:0] carry;

  always_comb begin
    for (int i = 0; i < 4; i++) begin
      generate_func[i] = a_i[i] & b_i[i];
    end
  end

  always_comb begin
    for (int i = 0; i < 4; i++) begin
      propagate_func[i] = a_i[i] | b_i[i];
    end
  end

  assign carry[0] = c_i;
  assign carry[1] = generate_func[0] | propagate_func[0] & carry[0];
  assign carry[2] = generate_func[1] | propagate_func[1] & carry[1];
  assign carry[3] = generate_func[2] | propagate_func[2] & carry[2];
  assign c_o      = generate_func[3] | propagate_func[3] & carry[3];

  generate
    genvar i;
    for (i = 0; i < 4; i++) begin
      fulladder inst1
      (
        .a_i    (a_i[i]  ),
        .b_i    (b_i[i]  ),
        .carry_i(carry[i]),
        .sum_o  (sum_o[i]),
        .carry_o(        )
      );
    end
  endgenerate
  
endmodule