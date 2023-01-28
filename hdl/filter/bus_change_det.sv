module bus_change_det #(
  parameter DWIDTH = 8
) (
  input               clk,
  input [WIDTH-1:0]   din,
  output              change
);

logic [WIDTH-1:0] din_r;

always_ff @(posedge clk, posedge rst) begin
  if (rst) begin
    din_r <= '0;
  end else begin
    din_r <= din;
  end
end

assign change = din_r != din;

    
endmodule