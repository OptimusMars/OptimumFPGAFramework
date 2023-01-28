// RS-latch
module rsl(
	input        r,
	input        s,
	output logic q
);

always_latch begin
  if      (r) q <= '0;
  else if (s) q <= '1;
  else        q <= q;
end
	
endmodule : rsl
