
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module vmemcic_top
#(
  parameter         WIDTH_I         = 16,               // Input data Width
  parameter         WIDTH_O         = 17,               // Output data Width
  parameter         STAGES          = 10,               // CIC filter stages
  parameter         MAX_DECIMATION  = 16,               // Maximum Decimation factor
  parameter         RATES           = 4,                // Output sample rates
  parameter integer DEC_ARR[RATES]  = '{2, 4, 8, 16},    // Decimation factor array
  // Localparam
  parameter         WIDTH_S         = $clog2(RATES)
)
(
  input                               clk_i,
  input                               rst_i, 
  
  input signed [WIDTH_I-1:0]          data_i,
  input                               data_val_i,
  input [WIDTH_S-1:0]                 dec_sel_i, 
  
  output logic                        data_val_o,
  output logic  signed [WIDTH_O-1:0]  data_o,
  
  output logic                        error
);
  
  
vmemcic #(
  .WIDTH_I          (WIDTH_I),
  .WIDTH_O          (WIDTH_O),
  .STAGES           (STAGES),
  .MAX_DECIMATION   (MAX_DECIMATION),
  .RATES            (RATES),
  .DEC_ARR          (DEC_ARR)
) vmemcic_instance (
  .clk_i            (clk_i),
  .rst_i            (rst_i),
  .data_i           (data_i),
  .data_val_i       (data_val_i),
  .dec_sel_i        (dec_sel_i),
  .data_val_o       (data_val_o),
  .data_o           (data_o),
  .error            (error)
);  

endmodule // vmemcic_top
