module tffe(
  input         clk,
  input         rst,
  input         t,
  input         ena,
  output logic  q
);
  
always_ff @ (posedge clk, posedge rst) 
  if      (rst)       q <= '0;
  else if (t && ena)  q <= ~q;
  else                q <= q;
  
endmodule : tffe