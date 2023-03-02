

module cic_integrator
#(
  parameter WIDTH = 64
)
(
  input                           clk_i,
  input                           clk_en_i,
  input                           reset_i,
  input signed [WIDTH-1:0]        data_i,
  output reg signed [WIDTH-1:0]   data_o
);

always @(posedge clk_i or posedge reset_i)
  if (reset_i) data_o <= 0;
  else if (clk_en_i) data_o <= data_o + data_i;

endmodule