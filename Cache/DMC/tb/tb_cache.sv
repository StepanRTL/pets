module tb_cache();

  logic        tb_clk;
  logic        tb_aresetn;
  logic        tb_wr_en;
  logic [31:0] tb_data_in;
  logic [31:0] tb_addr;
  logic [31:0] tb_data_out;
  logic        tb_hit;
  logic        tb_miss;

  direct_mapping_cache DUT
  (
    .clk_i         (tb_clk     ),
    .aresetn_i     (tb_aresetn ),
    .write_enable_i(tb_wr_en   ),
    .data_i        (tb_data_in ),
    .addr_i        (tb_addr    ),
    .data_o        (tb_data_out),
    .hit_o         (tb_hit     ),
    .miss_o        (tb_miss    )
  );

  initial begin
    tb_clk <= 1'b0;
    forever begin
      #1;
      tb_clk <= ~tb_clk;
    end
  end

  initial begin
    tb_aresetn <= 1'b0;
    @(posedge tb_clk);
    tb_aresetn <= 1'b1;
    tb_wr_en   <= 1'b1;
    repeat (5) begin
      tb_data_in <= $urandom;
      tb_addr    <= $urandom;
      @(posedge tb_clk);
    end
    tb_wr_en   <= 1'b0;
    tb_addr    <= 32'h328921ed;
  end

endmodule