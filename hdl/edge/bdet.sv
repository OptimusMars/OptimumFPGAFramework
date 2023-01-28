// Both-Edge detector module
module bdet (clk, in, out);

input clk;
input in;
output out;

edet #(.EDGE("BOTH")) e0 (.clk(clk), .in(in), .out(out));
  
endmodule 