// D-latch
module dl(
	input        d,
	input        ena,
	output logic q
);

always_comb begin
  if(ena) q <= d;
  else q <= q;
end
	
endmodule : dl
