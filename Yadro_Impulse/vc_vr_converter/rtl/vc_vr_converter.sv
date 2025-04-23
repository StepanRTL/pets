module vc_vr_converter #(
    parameter DATA_WIDTH = 8,
              CREDIT_NUM = 2
)(
    input  logic                    clk,
    input  logic                    rst_n,
    //valid/credit interface
    input  logic [DATA_WIDTH-1:0]   s_data_i,
    input  logic                    s_valid_i,
    output logic                    s_credit_o,

    //valid/ready interface
    output logic [DATA_WIDTH-1:0]   m_data_o,
    output logic                    m_valid_o,
    input  logic                    m_ready_i
);

  logic                           pop;
  logic                           empty;
  logic  [$clog2(CREDIT_NUM) : 0] cnt;
  logic  [CREDIT_NUM - 1:0]       num_of_credits;

  assign pop       = m_valid_o && m_ready_i;
  assign m_valid_o = ~empty;


  fifo #(.DEPTH(CREDIT_NUM), .WIDTH(DATA_WIDTH)) inst
  (
    .clk_i            (clk          ),
    .rstn_i           (rst_n        ),
    .data_i           (s_data_i     ),
    .push_i           (s_valid_i    ),
    .pop_i            (pop          ),
    .empty_o          (empty        ),
    .data_o           (m_data_o     ),
    .full_o           (             )
  );


  always_ff @(posedge clk)
    if (~rst_n)
      num_of_credits <= CREDIT_NUM;


  always_ff @(posedge clk)
    if (~rst_n)
      cnt <= 'b0;
    else if (cnt < num_of_credits)
      cnt <= cnt + 'b1;

  assign s_credit_o = ~s_valid_i && pop || (cnt < num_of_credits);






endmodule
