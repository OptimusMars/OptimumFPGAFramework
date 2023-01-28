// Ripple counter
module ripplecnt
#(
  parameter DWIDTH = 16
)
(
  input               clk,
  input               aclr,
  input               ena,
  input               dir,
  output [DWIDTH-1:0] q
);
  
genvar i;
logic [DWIDTH-1:1] clknext;

jkff jk0(.clk(clk), .j('1), .k('1), .q(q[0]));

generate for (i = 1; i < DWIDTH; i++) begin
assign clknext[i] = dir ? q[i-1] : !q[i-1];
jkff jk(.clk(clknext[i]), .j('1), .k('1), .q(q[i]));
end endgenerate
  
endmodule : ripplecnt
