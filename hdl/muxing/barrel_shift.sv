`timescale 1 ns / 1ns

module barrel_shift #(
	parameter RIGHT         = 1,                // Rotate  direction
  parameter WIDTH         = 16,               // Width of input signal
  parameter DIST_WIDTH    = $clog2(WIDTH),    // Rotate distance
  parameter GENERIC       = 0                 // Generic Barrel Shifter Implementation 
) 
(
	input   [WIDTH-1:0]       din,              // Input Data
  input   [DIST_WIDTH-1:0]  distance,         // Rotate Distance
  output  [WIDTH-1:0]       dout              // Output Data
);

wire [WIDTH-1:0] din_int, dout_int;

function logic [WIDTH-1:0] reverse_vector(logic [WIDTH-1:0] din);
  automatic logic [WIDTH-1:0] ret = '0;
  for (int i = 0; i < WIDTH; i++) begin
			ret[i] = din[WIDTH-1-i];
  end
  return ret;
endfunction

assign din_int = RIGHT ? din : reverse_vector(din);   // input reversal for ROL

// rotate right sorting network
rotate_internal  #(
  .WIDTH      (WIDTH),
  .DIST_WIDTH (DIST_WIDTH),
  .GENERIC    (GENERIC)
) rotate_internal_inst (
  .din      (din_int),
  .dout     (dout_int),
  .distance (distance)
);

assign dout = RIGHT ? dout_int : reverse_vector(dout_int);  // output reversal for ROL

endmodule
