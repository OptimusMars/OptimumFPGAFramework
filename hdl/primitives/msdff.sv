// Master-Slave DFF
module msdff(
	input  clk,
	input  d,
	output q
);

logic q0, q1;

dl dl0 (.d(d), .ena(clk), .q(q0));
dl dl1 (.d(q0), .ena(!clk), .q(q));
	
endmodule : msdff
