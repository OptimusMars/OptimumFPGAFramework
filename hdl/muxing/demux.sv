module demux #(
  parameter DWIDTH    = 16,
  parameter OUTPUTS   = 4
) (
  input                         clk,  
  input [DWIDTH-1:0]            data,       
  input                         en,
  input [$clog2(OUTPUTS)-1:0]   sel,
  output [DWIDTH*OUTPUTS-1:0]   q  
);

localparam OUTPUTS_POW2 = 1 << $clog2(OUTPUTS);

logic [OUTPUTS_POW2*DWIDTH-1:0] data_wide = '0;

always_ff @(posedge clk)
  if(en) data_wide[sel] <= data;

assign q = data_wide[$size(q)-1:0];

endmodule