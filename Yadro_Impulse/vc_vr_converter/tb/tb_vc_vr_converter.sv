module tb_vc_vr_converter();

  localparam DATA_WIDTH = 8;
  localparam CREDIT_NUM = 2;

  logic                    tb_clk;
  logic                    tb_resetn;
  logic [DATA_WIDTH - 1:0] s_data;
  logic                    s_valid;
  logic                    s_credit;
  logic [DATA_WIDTH - 1:0] m_data;
  logic                    m_valid;
  logic                    m_ready;

  vc_vr_converter #(.DATA_WIDTH(DATA_WIDTH), .CREDIT_NUM(CREDIT_NUM)) DUT
  (
    .clk       (tb_clk   ),
    .rst_n     (tb_resetn),
    .s_data_i  (s_data   ),
    .s_valid_i (s_valid  ),
    .s_credit_o(s_credit ),
    .m_data_o  (m_data   ),
    .m_valid_o (m_valid  ),
    .m_ready_i (m_ready  )
  );

  task task_reset();
    tb_resetn <= 1'b0;
    s_valid   <= 1'b0;
    m_ready   <= 1'b0;
    repeat (10) @(posedge tb_clk);

    if (m_valid !== 0 || s_credit !== 0)
      $error("Reset failed!");
    tb_resetn <= 1'b1;
    repeat (5) @(posedge tb_clk);
    if (DUT.num_of_credits !== CREDIT_NUM)
      $error("Credit init failed!");
  endtask

  task task_single_transfer(input logic [7:0] test_data);
    s_data  <= test_data;
    s_valid <= 1'b1;
    repeat (2) @(posedge tb_clk);
    s_valid <= 1'b0;
    if (m_valid !== 1)
      $error("Transfer not accepted!");
    m_ready <= 1'b1;
    if (m_data !== test_data || s_credit !== 1)
        $error("Data mismatch!");
  endtask

  initial begin
    tb_clk <= 1'b0;
    forever begin
      #1;
      tb_clk <= ~tb_clk;
    end
  end

  initial begin
    task_reset();
    task_single_transfer($urandom);
    @(posedge tb_clk);
    task_single_transfer($urandom);
    @(posedge tb_clk);
    task_single_transfer($urandom);
    @(posedge tb_clk);
    task_single_transfer($urandom);
    @(posedge tb_clk);
    task_single_transfer($urandom);
    @(posedge tb_clk);
    task_single_transfer($urandom);
    @(posedge tb_clk);
  end

endmodule
