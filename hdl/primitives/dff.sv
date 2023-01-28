module dff (
	input        clk,
	input        rst,
	input        d,
	output logic q
);

always_ff @(posedge clk, posedge rst) 
  if(rst) q <= '0;
  else q <= d;

endmodule : dff
