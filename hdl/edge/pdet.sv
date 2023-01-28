// Pos-Edge detector module
module pdet (clk, in, out);

input clk;
input in;
output out;

edet #(.EDGE("POS")) e0 (.clk(clk), .in(in), .out(out));
  
endmodule 