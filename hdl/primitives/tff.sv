module tff(
	input        clk,
	input        rst,
	input        t,
	output logic q
);
	
always_ff @ (posedge clk, posedge rst) 
  if      (rst) q <= '0;
  else if (t)   q <= ~q;
  else          q <= q;
	
endmodule : tff
