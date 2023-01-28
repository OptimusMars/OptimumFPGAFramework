module usedcalc
#(
  parameter WIDTH = 16    
)
(
  input         [WIDTH-1:0]   wrcnt,
  input         [WIDTH-1:0]   rdcnt,
  output logic  [WIDTH-1:0]   used
);

localparam logic [WIDTH:0] SIZE = 1 << WIDTH;

logic [WIDTH:0] used_long;
assign used_long = (SIZE - (rdcnt - wrcnt));

always_comb begin
  if(wrcnt >= rdcnt) used <= wrcnt - rdcnt;
  else used <= used_long[WIDTH-1:0];
end
	
endmodule
