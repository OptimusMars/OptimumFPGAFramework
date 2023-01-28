// JK-latch
module jkl(
	input          j,
	input          k,
	output logic   q
);

always_latch begin
  if        (j && k)  q <= ~q;
  else if   (k)       q <= '0;
  else if   (j)       q <= '1;
  else                q <= q;
end

endmodule
