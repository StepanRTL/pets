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

  logic                     push1;
  logic                     push2;
  logic                     m_handshake;
  logic                     pop1;
  logic                     pop2;
  logic                     full1;
  logic                     full2;
  logic [3:0]               compare_id1;
  logic [3:0]               compare_id2;
  logic [DATA_WIDTH + 3: 0] data_for_fifo2;
  logic [DATA_WIDTH + 3: 0] data_from_fifo2;
  logic [DATA_WIDTH + 3: 0] data_for_fifo2_ff;
  logic                     same_id1;
  logic                     same_id2;

  assign m_handshake    = m_arvalid_o && m_arready_i;
  assign pop1           = m_handshake && same_id1;
  assign push1          = s_arvalid_i && s_arready_o;
  assign push2          = m_handshake && ~same_id1;
  assign pop2           = same_id2;

  assign data_for_fifo2 = {m_rdata_i, m_rid_i};
  assign compare_id2    = data_from_fifo2[3:0];

  always_ff @(posedge clk)
    if (~rst_n)
      data_for_fifo2_ff <= 'b0;
    else
      data_for_fifo2_ff <= data_for_fifo2;

  show_ahead_fifo #(.WIDTH(4), .DEPTH(16)) show_ahead_fifo_for_id
  (
    .clk_i  (clk        ),
    .rstn_i (rst_n      ),
    .push_i (push1      ),
    .pop_i  (pop1       ),
    .data_i (s_arid_i   ),
    .data_o (compare_id1),
    .empty_o(           ),
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
    .empty_o(                 ),
    .full_o (full2            )
  );


  assign m_arid_o     = s_arid_i;
  assign m_arvalid_o  = s_arvalid_i;

  assign s_arready_o  = ~full1;                              // while show_ahead_for_id isn`t full, it can accept new id
  assign m_rready_o   = ~full2;                              // while show_ahead_for_id_and_data isn`t full, it can accept new data with id
  assign s_rvalid_o   = pop2;                                // the signal indicates a situation when show_ahead_for_id_and_data bring new data
  assign s_rid_o      = same_id1 ? m_rid_i : compare_id2;                         // output id
  assign s_rdata_o    = same_id1 ? data_for_fifo2_ff : data_from_fifo2[DATA_WIDTH + 3 : 4]; // output data
  assign same_id1     = compare_id1 == m_rid_i;
  assign same_id2     = compare_id1 == compare_id2;
endmodule
