module reorder_buffer #( parameter DATA_WIDTH = 8) (
  input  logic                  clk,
  input  logic                  rst_n,
  //AR slave interface
  input  logic [3:0]            s_arid_i,
  input  logic                  s_arvalid_i,
  output logic                  s_arready_o,
  //R slave interface
  output logic [DATA_WIDTH-1:0] s_rdata_o,
  output logic [3:0]            s_rid_o,
  output logic                  s_rvalid_o,
  input  logic                  s_rready_i,
  //AR master interface
  output logic [3:0]            m_arid_o,
  output logic                  m_arvalid_o,
  input  logic                  m_arready_i,
  //R master interface
  input  logic [DATA_WIDTH-1:0] m_rdata_i,
  input  logic [3:0]            m_rid_i,
  input  logic                  m_rvalid_i,
  output logic                  m_rready_o
);

  logic       push1;
  logic       pop1;
  logic       empty_fifo1;
  logic       empty_fifo2;
  logic [3:0] compare_id1;
  logic       id_match;

  assign id_match = compare_id1 == m_rid_i;

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      s_rvalid_o <= 1'b0;
      s_rdata_o  <= 'b0;
      s_rid_o    <= 'b0;
    end
    else if (id_match && ~empty_fifo1) begin
      s_rvalid_o <= m_rvalid_i;
      s_rid_o    <= m_rid_i;
      s_rdata_o  <= m_rdata_i;
    end
  end


  assign push1 = s_arvalid_i && s_arready_o;
  show_ahead_fifo #(.WIDTH(4), .DEPTH(16)) show_ahead_fifo_for_id
  (
    .clk_i  (clk        ),
    .rstn_i (rst_n      ),
    .push_i (push1      ),
    .pop_i  (pop1       ),
    .data_i (s_arid_i   ),
    .data_o (compare_id1),
    .empty_o(empty_fifo1),
    .full_o (full1      )
  );

  show_ahead_fifo #(.WIDTH(DATA_WIDTH + 4), .DEPTH(16)) show_ahead_fifo_for_id_and_data
  (
    .clk_i  (clk              ),
    .rstn_i (rst_n            ),
    .push_i (push2            ),
    .pop_i  (pop2             ),
    .data_i (data_for_fifo2_ff),
    .data_o (data_from_fifo2  ),
    .empty_o(empty_fifo2      ),
    .full_o (full2            )
  );

  assign m_arid_o    = s_arid_i;
  assign m_arvalid_o = s_arvalid_i;
  assign m_rready_o  = m_rid_i == compare_id1;

endmodule
