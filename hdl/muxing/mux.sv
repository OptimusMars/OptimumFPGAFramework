module mux #(
  parameter DWIDTH    = 16,
  parameter INPUTS    = 4
) (
  input [DWIDTH*INPUTS-1:0]   data,
  input [$clog2(INPUTS)-1:0]  sel,
  output [DWIDTH-1:0]         q  
);

localparam INPUTS_POW2 = 1 << $clog2(INPUTS);

logic [INPUTS_POW2*DWIDTH-1:0] data_wide;

assign data_wide = data;
assign q = data_wide[sel*DWIDTH +: DWIDTH];

endmodule
