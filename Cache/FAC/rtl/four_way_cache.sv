module four_way_cache #(parameter DATA_WIDTH  = 32,
                        parameter ADDR_WIDTH  = 32,
                        parameter DEPTH_CACHE = 8,
                        parameter NUM_SECTION = 4) (
  input  logic                    clk_i,
  input  logic                    aresetn_i,
  input  logic                    write_enable_i,
  input  logic [DATA_WIDTH - 1:0] data_i,
  input  logic [ADDR_WIDTH - 1:0] addr_i,
  output logic [DATA_WIDTH - 1:0] data_o,
  output logic                    hit_o,
  output logic                    miss_o
);

  logic [NUM_SECTION - 1:0] hits;
  
  generate
    genvar i;
    for (int i = 0; i < NUM_SECTION; i = i + 1) begin
      direct_mapping_cache inst1 
      (
        .clk_i         (clk_i),
        .aresetn_i     (aresetn_i),
        .write_enable_i(),
        .data_i        (),
        .addr_i        (),
        .data_o        (),
        .hit_o         (),
        .miss_o        ()
      );
    end
  endgenerate
endmodule