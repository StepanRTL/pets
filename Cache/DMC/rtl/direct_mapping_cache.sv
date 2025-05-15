module direct_mapping_cache #(parameter DATA_WIDTH  = 32,
                              parameter ADDR_WIDTH  = 32,
                              parameter DEPTH_CACHE = 8) (
  input  logic                    clk_i,
  input  logic                    aresetn_i,
  input  logic                    write_enable_i,
  input  logic [DATA_WIDTH - 1:0] data_i,
  input  logic [ADDR_WIDTH - 1:0] addr_i,
  output logic [DATA_WIDTH - 1:0] data_o,
  output logic                    hit_o,
  output logic                    miss_o
);
  localparam WIDTH_NUMBER_OF_SET = $clog2(DEPTH_CACHE);         // количество бит, необходимое для хранения номера множества
  localparam WIDTH_TAG = ADDR_WIDTH - WIDTH_NUMBER_OF_SET - 2;  // ширина тега

  logic [DATA_WIDTH + WIDTH_TAG : 0] cache [DEPTH_CACHE - 1:0]; // кэш память
  logic [WIDTH_NUMBER_OF_SET - 1: 0] num_of_set;                // номер множества
  logic [DEPTH_CACHE - 1 : 0]        valid_vector;              // вектор битов достоверности для каждого набора кэша
  logic                              equal_tag;                 // равенство входного тэга с уже имеющимся
  logic [WIDTH_TAG - 1 : 0]          tag_in_cache;              // тэг, уже имеющийся в кэше
  logic [WIDTH_TAG - 1 : 0]          input_tag;                 // тэг входных данных

  assign num_of_set   = addr_i[WIDTH_NUMBER_OF_SET + 1 : 2];
  assign tag_in_cache = cache[num_of_set][DATA_WIDTH + WIDTH_TAG - 1 : DATA_WIDTH];
  assign input_tag    = addr_i[ADDR_WIDTH - 1 : WIDTH_NUMBER_OF_SET + 1];
  assign equal_tag    = valid_vector[num_of_set] ? (tag_in_cache == input_tag) : 1'b0;
  assign hit_o        = valid_vector[num_of_set] && equal_tag;
  assign miss_o       = ~valid_vector[num_of_set];

  always_ff @(posedge clk_i or negedge aresetn_i)
    if (~aresetn_i)
      valid_vector <= {DEPTH_CACHE{1'b0}};
    else if (write_enable_i)
      valid_vector[num_of_set] <= 1'b1;

  always_ff @(posedge clk_i or negedge aresetn_i)
    if (~aresetn_i)
      data_o <= {DATA_WIDTH{1'b0}};
    else if (hit_o && ~write_enable_i)
      data_o <= cache[num_of_set][DATA_WIDTH - 1 : 0];

  always_ff @(posedge clk_i or negedge aresetn_i)
    if (write_enable_i) begin
      cache[num_of_set]        <= {input_tag, data_i};
    end
  

endmodule
