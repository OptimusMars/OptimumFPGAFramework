module muxpipe #(
  parameter DWIDTH    = 16,
  parameter INPUTS    = 4,
  parameter PIPELINE  = 0
) (
  input                       clk,
  input [DWIDTH*INPUTS-1:0]   data,
  input [$clog2(INPUTS)-1:0]  sel,
  output [DWIDTH-1:0]         q  
);



endmodule