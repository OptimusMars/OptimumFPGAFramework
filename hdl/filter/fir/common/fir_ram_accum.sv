//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_ram_accum.sv
//-- created     : 26 марта 2020 г. : 14:02:52	
//-- author      : Martynov Ivan
//-- company     : Expert Electronix, Taganrog, Russia
//-- target      : [x] simulation  [x] synthesis
//-- technology  : [x] any
//-- tools & o/s : quartus 13.1 & windows 7
//-- dependency  :
//-------------------------------------------------------------------------------
//-- description : Accumulator block for fir
//-- 
//--
//-------------------------------------------------------------------------------
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fir_ram_accum
#(
  parameter DWIDTH = 16,
  parameter ACWIDTH = 20
)
(
  input                         clk_i,
  input                         rst_i,
  input                         clr_i, 
  input                         clk_ena_i, 
  input signed [DWIDTH - 1:0]   data_i,
  output signed [ACWIDTH - 1:0] accum_o
);

logic signed [ACWIDTH - 1:0] accum;

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) accum <= '0;
  else if (clr_i) accum <= '0;
  else if (clk_ena_i) accum <= accum + data_i;
  
assign accum_o = accum;

endmodule // fir_ram_accum
