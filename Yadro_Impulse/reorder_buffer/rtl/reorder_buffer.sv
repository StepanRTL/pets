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

  logic                      push;
  logic                      pop;
  logic                      m_r_handshake;
  logic                      m_ar_handshake;
  logic                      s_r_handshake;
  logic                      empty_fifo;
  logic                      full_fifo;
  logic [3:0]                compare_id;
  logic                      id_match1;
  logic                      id_match2;
  logic [DATA_WIDTH - 1 : 0] data_to_ram;
  logic [DATA_WIDTH - 1 : 0] ram_for_data [15:0];
  logic [15:0]               register_of_valid_data_in_ram;

  assign m_r_handshake  = m_rvalid_i && m_rready_o;
  assign m_ar_handshake = m_arvalid_o && m_arready_i;
  assign id_match1      = (compare_id == m_rid_i) && m_r_handshake;
  assign id_match2      = register_of_valid_data_in_ram[compare_id] == 1'b1;
  assign pop            = ~empty_fifo && (id_match1 || id_match2) ? 1'b1 : 1'b0;
  assign push           = s_arvalid_i && s_arready_o;
  assign data_to_ram    = {m_rdata_i, m_rid_i};
  assign s_r_handshake  = s_rvalid_o && s_rready_i;
  assign s_rvalid_o     = register_of_valid_data_in_ram[compare_id] || m_rvalid_i;

  show_ahead_fifo #(.WIDTH(4), .DEPTH(16)) show_ahead_fifo_for_id
  (
    .clk_i  (clk       ),
    .rstn_i (rst_n     ),
    .push_i (push      ),
    .pop_i  (pop       ),
    .data_i (s_arid_i  ),
    .data_o (compare_id),
    .empty_o(empty_fifo),
    .full_o (full_fifo )
  );

  always_ff @(posedge clk) begin
    if (~rst_n)
      register_of_valid_data_in_ram              <= 16'b0;
    else if (~id_match1 && m_r_handshake) 
      register_of_valid_data_in_ram[m_rid_i]     <= 1'b1;
    else if (id_match2)
      register_of_valid_data_in_ram[compare_id]  <= 1'b0;
  end

  always_ff @(posedge clk)
    if (~id_match1 && m_r_handshake)
      ram_for_data[m_rid_i] <= data_to_ram;

  always_comb  begin
    if (id_match2 && s_r_handshake) begin
      s_rid_o    = compare_id;
      s_rdata_o  = ram_for_data[compare_id];
    end
    else if (id_match1 && s_r_handshake) begin
      s_rid_o    = m_rid_i;
      s_rdata_o  = m_rdata_i;
    end
    else begin
      s_rid_o    = 4'b0;
      s_rdata_o  = 'b0;
    end
  end

  assign m_arid_o    = m_ar_handshake ? s_arid_i : 4'b0;
  assign m_arvalid_o = s_arvalid_i;
  assign s_arready_o = ~full_fifo;
  assign m_rready_o  = ~(&register_of_valid_data_in_ram);

endmodule
