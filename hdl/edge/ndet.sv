// Pos-Edge detector module
module ndet (clk, in, out);

input clk;
input in;
output out;

edet #(.EDGE("NEG")) e0 (.clk(clk), .in(in), .out(out));
  
endmodule 