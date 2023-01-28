// JKFF
module jkff(
  input         clk,
  input         rst,
  input         j,
  input         k,
  output logic  q
);

always_ff @ (posedge clk, posedge rst)
  if      (rst)     q <= '0;
  else if (j && k)  q <= ~q;
  else if (k)       q <= '0;
  else if (j)       q <= '1;
  else              q <= q;

endmodule : jkff