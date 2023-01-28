// Gray counter
module gcnt
#(
  parameter WIDTH = 8    
)
(
	input clk, ena, aclr,
	output logic [WIDTH-1:0] gray_count
);

logic q [WIDTH-1:-1];  // q is the counter, plus the imaginary bit	
logic no_ones_below [WIDTH-1:-1];  // no_ones_below[x] = 1 iff there are no 1's in q below q[x]
logic q_msb;  // q_msb is a modification to make the msb logic work

always_ff @ (posedge aclr or posedge clk) begin
	if (aclr) begin
		q[-1] <= 1;  // Resetting involves setting the imaginary bit to 1
		for (i = 0; i <= WIDTH-1; i++) q[i] <= '0;
	end
	else if (ena) begin
		q[-1] <= ~q[-1];   // Toggle the imaginary bit
		
		for (i = 0; i < WIDTH-1; i++)
			q[i] <= q[i] ^ (q[i-1] & no_ones_below[i-1]); // Flip q[i] if lower bits are a 1 followed by all 0's
		
		q[WIDTH-1] <= q[WIDTH-1] ^ (q_msb & no_ones_below[WIDTH-2]);
	end
end


always_comb begin
	no_ones_below[-1] <= '1;   // There are never any 1's beneath the lowest bit
	
	for (int j = 0; j < WIDTH-1; j++)
		no_ones_below[j] <= no_ones_below[j-1] & ~q[j-1];
		
	q_msb <= q[WIDTH-1] | q[WIDTH-2];
	
	for (int k = 0; k < 8; k++)   // Copy over everything but the imaginary bit
		gray_count[k] <= q[k];
end

endmodule
