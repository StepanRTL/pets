module tb_reorder_buffer();

  localparam DATA_WIDTH = 8;

  logic                    tb_clk;
  logic                    tb_rstn;
  logic [3:0]              s_arid_i;
  logic                    s_arvalid_i;
  logic                    s_arready_o;
  logic [DATA_WIDTH - 1:0] s_rdata_o;
  logic [3:0]              s_rid_o;
  logic                    s_rvalid_o;
  logic                    s_rready_i;
  logic [3:0]              m_arid_o;
  logic                    m_arvalid_o;
  logic                    m_arready_i;
  logic [DATA_WIDTH-1:0]   m_rdata_i;
  logic [3:0]              m_rid_i;
  logic                    m_rvalid_i;
  logic                    m_rready_o;

  reorder_buffer #(.DATA_WIDTH(DATA_WIDTH)) DUT 
  (
    .clk        (tb_clk     ),
    .rst_n      (tb_rstn    ),
    .s_arid_i   (s_arid_i   ),
    .s_arvalid_i(s_arvalid_i),
    .s_arready_o(s_arready_o),
    .s_rdata_o  (s_rdata_o  ),
    .s_rid_o    (s_rid_o    ),
    .s_rvalid_o (s_rvalid_o ),
    .s_rready_i (s_rready_i ),
    .m_arid_o   (m_arid_o   ),
    .m_arvalid_o(m_arvalid_o),
    .m_arready_i(m_arready_i),
    .m_rdata_i  (m_rdata_i  ),
    .m_rid_i    (m_rid_i    ),
    .m_rvalid_i (m_rvalid_i ),
    .m_rready_o (m_rready_o )
  );   

  initial begin
    tb_clk <= 1'b0;
    forever begin
      #5;
      tb_clk <= ~tb_clk;
    end
  end

  initial begin
    tb_rstn <= 1'b0;
    @(posedge tb_clk);
    tb_rstn <= 1'b1;
    m_arready_i <= 1'b1;
    m_rvalid_i  <= 1'b0;
    s_rready_i  <= 1'b1;
    //@(posedge tb_clk);
    //s_arvalid_i <= 1'b1;
    //s_arid_i    <= 4'h1;
    //@(posedge tb_clk);
    //s_arvalid_i <= 1'b0;
    //s_arid_i    <= 4'h0;
    //@(posedge tb_clk);
    //@(posedge tb_clk);
    //s_arvalid_i <= 1'b1;
    //s_arid_i    <= 4'h2;
    //@(posedge tb_clk);
    //s_arvalid_i <= 1'b0;
    //s_arid_i    <= 4'h0;
    //@(posedge tb_clk);
    //@(posedge tb_clk);
    //@(posedge tb_clk);
    //s_arvalid_i <= 1'b1;
    //s_arid_i    <= 4'h3;  
    //@(posedge tb_clk);  
    //s_arvalid_i <= 1'b0;
    //s_arid_i    <= 4'h0;
    //@(posedge tb_clk);
    //m_rvalid_i  <= 1'b1;
    //m_rdata_i   <= $urandom;
    //m_rid_i     <= 4'h2;
    //@(posedge tb_clk);
    //m_rvalid_i  <= 1'b0;
    //m_rdata_i   <= 'b0;
    //m_rid_i     <= 4'h0;
    //@(posedge tb_clk);
    //@(posedge tb_clk);
    //m_rvalid_i  <= 1'b1;
    //m_rdata_i   <= $urandom;
    //m_rid_i     <= 4'h1;
    //@(posedge tb_clk);
    //m_rvalid_i  <= 1'b0;
    //m_rdata_i   <= 'b0;
    //m_rid_i     <= 4'h0;
    //@(posedge tb_clk);
    //m_rvalid_i  <= 1'b1;
    //m_rdata_i   <= $urandom;
    //m_rid_i     <= 4'h3;
    //@(posedge tb_clk);
    //m_rvalid_i  <= 1'b0;
    //m_rdata_i   <= 'b0;
    //m_rid_i     <= 4'h0;
    //@(posedge tb_clk);

    for (int i = 0; i < 16; i++) begin
      s_arid_i    <= i;
      s_arvalid_i <= 1'b1;
      @(posedge tb_clk);
    end
    @(posedge tb_clk);
    s_arid_i    <= 4'b0;
    s_arvalid_i <= 1'b0;
    @(posedge tb_clk);
    for (int i = 15; i >= 0; i--) begin
      m_rvalid_i  <= 1'b1;
      m_rdata_i   <= $urandom;
      m_rid_i     <= i;
      @(posedge tb_clk);
      m_rvalid_i  <= 1'b0;
      m_rdata_i   <= 'b0;
      m_rid_i     <= 4'b0;
      repeat ($urandom_range(1, 4)) @(posedge tb_clk);
    end
    repeat (3) @(posedge tb_clk);
    s_rready_i <= 1'b0;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    s_rready_i <= 1'b1;
  end

endmodule