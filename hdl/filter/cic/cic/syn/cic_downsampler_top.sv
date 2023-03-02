
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module cic_downsampler_top
#(
  parameter WIDTH_I       = 16,   // Input data width
  parameter WIDTH_O       = 17,   // Input data width
  parameter DECIMATION    = 64,   // Decimation Factor
  parameter STAGES        = 5     // Integrator-Comb stages
)
(
  input                               clk_i,          // Clock
  input                               rst_i,          // Async Reset
  // Input signal bus
  input   signed  [WIDTH_I - 1:0]     data_i,         // Input data for decimation
  input                               data_val_i,     // Input data valid signal
  
  // Output signal bus
  output  signed  [WIDTH_O - 1:0]     data_o,         // Output data with cic gain
  output  logic                       data_val_o     // Output data valid
);

cic_downsampler #(
  .WIDTH_I      (WIDTH_I),
  .WIDTH_O      (WIDTH_O),
  .DECIMATION   (DECIMATION),
  .STAGES       (STAGES)
) cic_downsampler_instance (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .data_i         (data_i),
  .data_val_i     (data_val_i),
  .data_o         (data_o),
  .data_val_o     (data_val_o)
);

endmodule // cic_downsampler_top
