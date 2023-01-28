`timescale 1 ns / 1ns
module rotate_internal 
#(
	parameter WIDTH = 16,
	parameter DIST_WIDTH = $clog2(WIDTH),
	parameter GENERIC = 0
)(
	input [WIDTH-1:0]       din,
	output [WIDTH-1:0]      dout,
	input [DIST_WIDTH-1:0]  distance
);

localparam MAX_D = 1 << DIST_WIDTH; // The shifting range described by the distance. 

// this subdesign does not allow shifting beyond the data width
// e.g. rotating an 8 bit value 100 steps.  
initial begin 
	#10
	if (MAX_D > WIDTH) begin
		$display ("Error - Rotation by distance greater than data width not supported");
		$stop();
	end
end

wire [2*WIDTH-1:0] double_din = {din,din};

genvar i;
generate
	if (GENERIC) begin
		assign dout = double_din >> distance;
	end
	else begin
		wire [WIDTH-1:0] layer;
		
		if (DIST_WIDTH == 0) begin //! degenerate case
			assign dout = din;
		end
		else if (DIST_WIDTH == 1) begin //! knock out the last distance line
			for (i = 0; i < WIDTH; i++) begin : two_to_one
				assign layer[i] = distance[0] ? double_din[i+1] : double_din[i];
			end		
			assign dout = layer;	
		end 
		else begin
			// knock out 2 more distance lines
			for (i=0;i<WIDTH;i=i+1) begin : four_to_one
				wire [3:0] dt;
				wire [1:0] st;
				assign dt[0] = double_din[i];
				assign dt[1] = double_din[i+MAX_D/4];
				assign dt[2] = double_din[i+MAX_D/2];
				assign dt[3] = double_din[i+MAX_D/2+MAX_D/4];
				assign st = {distance[DIST_WIDTH-1],distance[DIST_WIDTH-2]};
				assign layer[i] = dt[st];
			end
			if (DIST_WIDTH == 2) assign dout = layer;
			else begin
				// recurse to build the rest of the network
				rotate_internal #(.WIDTH(WIDTH), .DIST_WIDTH(DIST_WIDTH-2)) 
        		r (.din(layer),.dout(dout), .distance(distance[DIST_WIDTH-3:0]));
			end
		end
	end
endgenerate

endmodule
