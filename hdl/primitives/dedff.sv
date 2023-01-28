// Dual Edge DFF
module dedff(
	input        clk,
	input        rst,
	input        d,
	output logic q
);

logic q0, q1;
dff d0 (.clk(!clk), .rst(rst), .d(d), .q(q0));
dff d1 (.clk(clk), .rst(rst), .d(d), .q(q1));

assign q = clk ? q0 : q1;
	
endmodule : dedff
