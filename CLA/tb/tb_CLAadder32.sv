module tb_CLAadder32();

  logic tb_clk;
  logic tb_aresetn;
  logic [31:0] tb_a;
  logic [31:0] tb_b;
  logic tb_carry_in;
  logic tb_carry_out;
  logic [31:0] tb_sum;

    CLA_fulladder32 DUT
    (
      .clk_i(tb_clk),
      .aresetn_i(tb_aresetn),
      .a_i(tb_a),
      .b_i(tb_b),
      .carry_i(tb_carry_in),
      .sum_o(tb_sum),
      .carry_o(tb_carry_out)
    );

  initial begin
    tb_clk <= 1'b0;
    forever begin
      #1;
      tb_clk <= ~tb_clk;
    end
  end  

  initial begin
    tb_aresetn  <= 1'b0;
    @(posedge tb_clk);
    tb_aresetn  <= 1'b1;
    tb_carry_in <= 1'b0;
    repeat(11) begin
      tb_a <= $urandom_range(1, 2000);
      tb_b <= $urandom_range(1, 2000);
      @(posedge tb_clk);
      @(posedge tb_clk);
      if (tb_sum != tb_a + tb_b) $display("ERROR!!!");
    end
  end

endmodule