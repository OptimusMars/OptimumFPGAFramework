//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : Project
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_ram_sceleton.sv
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

module fir_ram_sceleton
#(
  parameter FILTER_ORDER      = 256,
  parameter COEF_FILE         = "fir_coef.mif", // FIR coefficient filename
  parameter DATA_WIDTH        = 16,
  parameter COEF_WIDTH        = 16,
  parameter PARALLEL          = 4,
  parameter USE_COEF_WRITE    = 0,
  parameter OUT_WIDTH         = 16,
  parameter PROCESSING_TYPE   = "TRUNC",
  parameter COEF_AWIDTH       = $clog2(FILTER_ORDER)
)
(
  input                             clk_i,
  input                             rst_i,
  
  input signed [DATA_WIDTH - 1:0]   data_i,
  input                             data_val_i,
  
  input                             coef_we_i,
  input [COEF_AWIDTH - 1:0]         coef_addr_i,
  input [COEF_WIDTH - 1:0]          coef_data_i,
  
  output signed [OUT_WIDTH - 1:0]   data_o,
  output [1:0]                      err_flg_o
);

initial begin
  if ( COEF_AWIDTH != $clog2(FILTER_ORDER))
    $error("COEF_AWIDTH cannot be overwritten");
end

logic   [COEF_AWIDTH*PARALLEL-1:0]   coef_read_addr;
logic   [COEF_WIDTH*PARALLEL-1:0]    coef_read_data;

// Coeficients ram
fir_ram_coef_ram #(
  .COEF_FILE        (COEF_FILE),
  .COEF_WIDTH       (COEF_WIDTH),
  .COEF_AWIDTH      (COEF_AWIDTH),
  .PORTS            (PARALLEL),
  .USE_COEF_WRITE   (USE_COEF_WRITE)
) fir_ram_coef_ram_instance (
  .clk_i            (clk_i),
  .rst_i            (rst_i),
  .coef_we_i        (coef_we_i),
  .coef_addr_i      (coef_addr_i),
  .coef_data_i      (coef_data_i),
  .coef_read_addr_i (coef_read_addr),
  .coef_read_data_o (coef_read_data)
);

logic                            data_rd;   // Read data from memory
logic [DATA_WIDTH*PARALLEL-1:0]  data;      // Readed data

// Data ram
fir_ram_data_ram #(
  .DATA_WIDTH   (DATA_WIDTH),
  .ORDER        (FILTER_ORDER),
  .PORTS        (PARALLEL)
) fir_ram_data_ram_instance (
  .clk_i        (clk_i),
  .rst_i        (rst_i),
  .data_we_i    (data_val_i),
  .data_i       (data_i),
  .data_rd_i    (data_rd),
  .data_o       (data)
);
// Computation unit
fir_ram_cpu #(
  .FILTER_ORDER     (FILTER_ORDER),
  .DATA_WIDTH       (DATA_WIDTH),
  .COEF_WIDTH       (COEF_WIDTH),
  .COEF_AWIDTH      (COEF_AWIDTH),
  .PARALLEL         (PARALLEL),
  .OUT_WIDTH        (OUT_WIDTH),
  .PROCESSING_TYPE  (PROCESSING_TYPE)
) fir_ram_cpu_instance (
  .clk_i            (clk_i),
  .rst_i            (rst_i),
  .data_val_i       (data_val_i),
  .data_o           (data_o),
  .data_ram_rd_o    (data_rd),
  .data_ram_i       (data),
  .coef_read_addr_o (coef_read_addr),
  .coef_read_data_i (coef_read_data),
  .err_flg_o        (err_flg_o)
);

endmodule // fir_ram_4mult
