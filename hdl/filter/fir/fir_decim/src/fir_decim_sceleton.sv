//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : Project
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_interp_sceleton.sv
//-- created     : 15 апреля 2020 г. : 10:14:14	
//-- author      : Martynov Ivan
//-- company     : Expert Electronix, Taganrog, Russia
//-- target      : [x] simulation  [x] synthesis
//-- technology  : [x] any
//-- tools & o/s : quartus 13.1 & windows 7
//-- dependency  :
//-------------------------------------------------------------------------------
//-- description : 
//-- 
//--
//-------------------------------------------------------------------------------
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fir_decim_sceleton
#(
  parameter FILTER_ORDER      = 256,
  parameter DECIMATION        = 32, 
  parameter COEF_FILE         = "fir_decim.mif", // FIR coefficient filename
  parameter DATA_WIDTH        = 16,
  parameter COEF_WIDTH        = 16,
  parameter USE_COEF_WRITE    = 0,
  parameter OUT_WIDTH         = 16,
  parameter PROCESSING_TYPE   = "TRUNC",
  parameter COEF_AWIDTH       = $clog2(FILTER_ORDER)
)
(
  input                             clk_i,
  input                             rst_i,
  
  input signed [DATA_WIDTH - 1:0]   data_i,     // Input data
  input                             data_val_i, // Input data valid flag
  
  // Coefficients write signal
  input                             coef_we_i,  
  input [COEF_AWIDTH - 1:0]         coef_addr_i,
  input [COEF_WIDTH - 1:0]          coef_data_i,
  
  output signed [OUT_WIDTH - 1:0]   data_o,
  output                            data_val_o,
  
  output [1:0]                      err_flg_o
);

// Computation unit
fir_decim_cpu #(
  .FILTER_ORDER     (FILTER_ORDER),
  .DECIMATION       (DECIMATION),
  .COEF_FILE        (COEF_FILE),
  .DATA_WIDTH       (DATA_WIDTH),
  .COEF_WIDTH       (COEF_WIDTH),
  .COEF_AWIDTH      (COEF_AWIDTH),
  .OUT_WIDTH        (OUT_WIDTH),
  .PROCESSING_TYPE  (PROCESSING_TYPE)
) fir_decim_cpu_instance (
  .clk_i            (clk_i),
  .rst_i            (rst_i),
  .data_i           (data_i),
  .data_val_i       (data_val_i),
  .coef_we_i        (coef_we_i),
  .coef_addr_i      (coef_addr_i),
  .coef_data_i      (coef_data_i),
  .data_o           (data_o),
  .data_val_o       (data_val_o),
  .err_flg_o        (err_flg_o)
);

endmodule 
