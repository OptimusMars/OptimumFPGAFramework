
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module varcic_sel
#(
  parameter WIDTH_ALL   = 64,       // Input great vector
  parameter WIDTH_I     = 16,       // Input data width 
  parameter WIDTH_O     = WIDTH_I,  // Output data width
  parameter STAGES      = 2,        // CIC stages
  parameter DECIMATION  = 2         // Decimation factor
)
(
  input signed [WIDTH_ALL - 1:0] data_i,
  output signed [WIDTH_O - 1: 0] data_o 
);

localparam WIDTH_GAIN = WIDTH_I + STAGES * $clog2(DECIMATION);    // Maximum output width

initial begin
  if(DECIMATION < 2) 
    $error("DECIMATION must be greather than 2");
  if(WIDTH_O > WIDTH_GAIN || WIDTH_O > WIDTH_ALL)
    $error("WIDTH_O parameter is wrong");
  if(WIDTH_GAIN > WIDTH_ALL)
    $error("WIDTH_GAIN exceeds WIDTH_ALL");
end

assign data_o = data_i[WIDTH_GAIN - 1:WIDTH_GAIN - WIDTH_O];

endmodule // varcic_sel
