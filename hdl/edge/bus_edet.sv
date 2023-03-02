module bus_edet #(
  parameter DWIDTH = 8
) (
  input               clk,
  input [DWIDTH-1:0]  din,
  output              change
);

logic [DWIDTH-1:0] din_d;

always_ff @(posedge clk) din_d <= din;

assign change = din_d != din;

endmodule