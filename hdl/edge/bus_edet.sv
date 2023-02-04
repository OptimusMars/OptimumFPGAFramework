module bus_edet #(
  parameter DWIDTH = 8
) (
  input               clk,
  input [WIDTH-1:0]   din,
  output              change
);

logic [WIDTH-1:0] din_d;

always_ff @(posedge clk, posedge rst)
  if (rst)  din_d <= '0;
  else      din_d <= din;

assign change = din_d != din;

endmodule