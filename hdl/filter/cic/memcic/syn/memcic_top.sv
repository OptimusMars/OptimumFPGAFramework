
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module memcic_top
#(
  parameter WIDTH_I     = 24,   // Input data Width
  parameter WIDTH_O     = 25,   // Input data Width
  parameter STAGES      = 10,   // CIC filter stages
  parameter DECIMATION  = 4     // Decimation factor
)
(
  input                           clk_i,
  input                           rst_i, 
  
  input signed [WIDTH_I-1:0]      data_i,
  input                           data_val_i,
  
  output                          data_val_o,
  output     signed [WIDTH_O-1:0] data_o,
  
  output                          error
);

memcic #(
  .STAGES       (STAGES),
  .DECIMATION   (DECIMATION),
  .WIDTH_I      (WIDTH_I),
  .WIDTH_O      (WIDTH_O)
) memcic_instance (
  .clk_i        (clk_i),
  .rst_i        (rst_i),
  .data_i       (data_i),
  .data_val_i   (data_val_i),
  .data_val_o   (data_val_o),
  .data_o       (data_o),
  .error        (error)
);



endmodule // memcic_top
