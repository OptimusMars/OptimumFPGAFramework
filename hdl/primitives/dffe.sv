module dffe (
  input         clk,
  input         rst,
  input         d,
  input         ena,
  output logic  q
);

always_ff @(posedge clk, posedge rst) 
  if      (rst) q <= '0;
  else if (ena) q <= d; 
  else          q <= q;

endmodule : dffe