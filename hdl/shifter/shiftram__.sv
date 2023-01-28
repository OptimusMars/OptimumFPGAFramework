module shiftram
#(
  parameter DWIDTH  = 16,
  parameter DEPTH   = 256
)
(
  input                 clk, 
  input                 shift,
  input   [DWIDTH-1:0]  d,
  output  [DWIDTH-1:0]  q
);

logic [DWIDTH-1:0] sr [DEPTH-1:0];

always @ (posedge clk) begin
  if (shift == 1'b1) begin
    for (int i = DEPTH-1; i > 0; i--) begin
      sr[i] <= sr[i-1];
    end
    sr[0] <= d;
  end
end

assign q = sr[DEPTH-1];

endmodule
