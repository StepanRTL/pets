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

  logic push1;
  logic push2;
  logic pop1;
  logic pop2;

  fifo fifo_for_id #(.WIDTH(), .DEPTH())
  (
    .clk_i(clk),
    .rstn_i(rst_n),
    .push_i(),
    .pop_i(),
    .data_i(),
    .data_o(),
    .empty_o(),
    .full_o()
  );

  fifo fifo_for_id_and_data #(.WIDTH(), .DEPTH())
  (
    .clk_i(clk),
    .rstn_i(rst_n),
    .push_i(),
    .pop_i(),
    .data_i(),
    .data_o(),
    .empty_o(),
    .full_o()
  );


endmodule