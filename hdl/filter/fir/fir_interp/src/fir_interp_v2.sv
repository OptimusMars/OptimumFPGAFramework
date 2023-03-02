//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR Interpolator
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_interp_v2.sv
//-- created     : 16 марта 2020 г. : 15:36:27	
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

module fir_interp_v2
#(
  parameter FILTER_ORDER      = 256,                  // Filter order 
  parameter INTERPOLATION     = 32,                   // Interpolation factor
  parameter COEF_FILE         = "fir_ram_coef.mif",   // FIR coefficient filename
  parameter DATA_WIDTH        = 16,                   // Input data width
  parameter COEF_WIDTH        = 16,                   // Filter coefficients width 
  parameter USE_COEF_WRITE    = 0,                    // Use coefficients memory writing
  parameter OUT_WIDTH         = 16,                   // Output width
  parameter PROCESSING_TYPE   = "LIMIT",              // Processing Type
  // Localparam
  parameter COEF_AWIDTH       = $clog2(FILTER_ORDER)  // 
)
(
  input                             clk_i,        
  input                             rst_i,
  
  input signed [DATA_WIDTH - 1:0]   data_i,     // Input data
  input                             data_val_i, // Input data valid flag
  
  // Coefficients write bus
  input                             coef_we_i,    // Write enable
  input [COEF_AWIDTH - 1:0]         coef_addr_i,  // Coefficient address
  input [COEF_WIDTH - 1:0]          coef_data_i,  // Coefficient data
  
  // FIFO not showahead
  output signed [OUT_WIDTH - 1:0]   data_o,       // Output data
  output                            data_val_o,   // Data valid signal
  
  output [1:0]                      err_flg_o     // Error flag during computing filter results
  
);

initial begin
  if(INTERPOLATION < 2) 
    $error("INTERPOLATION must be greater than 1");
  if(FILTER_ORDER % INTERPOLATION)
    $error("FILTER_ORDER must be multiple INTERPOLATION");
end


logic                             coef_we;
logic [COEF_AWIDTH - 1:0]         coef_addr;
logic [COEF_WIDTH - 1:0]          coef_data;

// Write interface blocking
always_comb begin
  if(USE_COEF_WRITE == 0) begin
    coef_we <= '0;
    coef_addr <= '0;
    coef_data <= '0;
  end
  else begin
    coef_we <= coef_we_i;
    coef_addr <= coef_addr_i;
    coef_data <= coef_data_i;
  end
end

fir_interp_sceleton_v2 #(
  .FILTER_ORDER     (FILTER_ORDER),
  .INTERPOLATION    (INTERPOLATION),
  .COEF_FILE        (COEF_FILE),
  .DATA_WIDTH       (DATA_WIDTH),      
  .COEF_WIDTH       (COEF_WIDTH),
  .COEF_AWIDTH      (COEF_AWIDTH),
  .USE_COEF_WRITE   (USE_COEF_WRITE),
  .OUT_WIDTH        (OUT_WIDTH),
  .PROCESSING_TYPE  (PROCESSING_TYPE)
) fir_interp_sceleton_v2_inst (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .data_i         (data_i),
  .data_val_i     (data_val_i),
  .coef_we_i      (coef_we),
  .coef_addr_i    (coef_addr),
  .coef_data_i    (coef_data),
  .data_o         (data_o),
  .data_val_o     (data_val_o),
  .err_flg_o      (err_flg_o)
);



endmodule // fir_interp_v2
