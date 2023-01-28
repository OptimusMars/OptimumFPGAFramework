// Edge detector module
module edet (clk, in, out);
  parameter string EDGE = "POS"; // "POS" "NEG" , "BOTH" - Edge detector type  
  
  initial begin
    if(EDGE != "POS" && EDGE != "NEG" && EDGE != "BOTH")
      $error("Block %s: parameter EDGE is illegal", `__FILE__);
  end
  
  input clk;
  input in;
  output out;
  
  logic in_d;
  
  always_ff @ (posedge clk) in_d <= in;
  
  generate 
    if (EDGE == "POS") assign out = in & ~in_d;
    else if (EDGE == "NEG") assign out = ~in & in_d;
    else if (EDGE == "BOTH") assign out = in ^ in_d;
  endgenerate 
  
endmodule 