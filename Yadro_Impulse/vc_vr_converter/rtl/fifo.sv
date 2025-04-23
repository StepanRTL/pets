module fifo #(parameter WIDTH = 8, DEPTH = 10)(
  input                clk_i,
  input                rstn_i,
  input                push_i,
  input                pop_i,
  input  [WIDTH - 1:0] data_i,
  output [WIDTH - 1:0] data_o,
  output               empty_o,
  output               full_o
);

  localparam WIDTH_PTR = $clog2(DEPTH);
  localparam MAX_PTR   = WIDTH_PTR' (DEPTH - 1);


  logic [WIDTH_PTR:0] wr_ptr;
  logic [WIDTH_PTR:0] rd_ptr;
  logic               wr_ptr_odd_circle;
  logic               rd_ptr_odd_circle;
  logic               equal_ptrs;
  logic               same_circle;

  logic [WIDTH - 1:0] ram [0: DEPTH - 1];

  assign equal_ptrs  = (wr_ptr == rd_ptr);
  assign same_circle = (wr_ptr_odd_circle == rd_ptr_odd_circle);

  always_ff @ (posedge clk_i or negedge rstn_i)
    if (~rstn_i) begin
      wr_ptr <= '0;
      wr_ptr_odd_circle <= 1'b0;
    end
    else if (push_i) begin
      if (wr_ptr == MAX_PTR) begin
        wr_ptr <= '0;
        wr_ptr_odd_circle <= ~ wr_ptr_odd_circle;
      end
      else
        wr_ptr <= wr_ptr + 1'b1;
    end

  always_ff @ (posedge clk_i or negedge rstn_i)
    if (~rstn_i) begin
      rd_ptr <= '0;
      rd_ptr_odd_circle <= 1'b0;
    end
    else if (pop_i)
    begin
      if (rd_ptr == MAX_PTR) begin
        rd_ptr <= '0;
        rd_ptr_odd_circle <= ~ rd_ptr_odd_circle;
      end
      else
        rd_ptr <= rd_ptr + 1'b1;
    end


  always_ff @ (posedge clk_i)
    if (push_i)
      ram [wr_ptr] <= data_i;

  assign data_o  = ram [rd_ptr];
  assign empty_o = equal_ptrs & same_circle;
  assign full_o  = equal_ptrs & ~same_circle;


endmodule

