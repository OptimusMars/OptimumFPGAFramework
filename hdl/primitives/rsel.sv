// RSE-latch
module rsel(
	input          r,
	input          s,
	input          ena,
	output logic   q
);

always_latch begin
  if        (ena) begin
    if      (r) q <= '0;
    else if (s) q <= '1;
    else        q <= q;
  end
  else
                q <= q;
end
	
endmodule : rsel
