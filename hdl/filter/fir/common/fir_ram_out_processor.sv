//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_ram_out_processor.sv
//-- created     : 15 марта 2020 г. : 11:16:40	
//-- author      : Martynov Ivan
//-- company     : Expert Electronix, Taganrog, Russia
//-- target      : [x] simulation  [x] synthesis
//-- technology  : [x] any
//-- tools & o/s : quartus 13.1 & windows 7
//-- dependency  :
//-------------------------------------------------------------------------------
//-- description : Output result processing unit
//-- 
//--
//-------------------------------------------------------------------------------

// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fir_ram_out_processor 
#(
  parameter IWIDTH  = 24,      // Input width
  parameter OWIDTH  = 16,      // Output width
  parameter SHIFT   = 16,      // Arithmetic shift value
  parameter TYPE    = "TRUNC"  // "TRUNC", "LIMIT", "ROUND"
)
(
  input                         clk_i,
  input                         rst_i,
  
  input  signed [IWIDTH - 1:0]  data_i,
  output signed [OWIDTH - 1:0]  data_o, 
  output logic                  data_limited_o
);

localparam signed MAX_VALUE = 2**(OWIDTH-1) - 1;
localparam signed MIN_VALUE = $signed(-MAX_VALUE);
localparam WIDTH = IWIDTH - (SHIFT - 1);

logic signed [OWIDTH - 1:0]     data;
logic signed [WIDTH - 1:0]      data_pre_lim;
logic                           lim_max;
logic                           lim_min;

typedef logic signed [OWIDTH - 1:0] data_t;

always_comb begin
  // data_pre_lim <= data_i >>> SHIFT;
  data_pre_lim <= $signed(data_i[IWIDTH - 1: SHIFT - 1]);      // Getting significant part of accumulator

  lim_max <= data_pre_lim > MAX_VALUE;
  lim_min <= data_pre_lim < MIN_VALUE;
  
end

assign data_limited_o = lim_max || lim_min;

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) data <= '0;
  else begin
    if(TYPE == "TRUNC")
      data <= data_pre_lim;
    else if (TYPE == "LIMIT") begin
      if(lim_max) data <= data_t'(MAX_VALUE);
      else if(lim_min) data <= data_t'(MIN_VALUE);
      else data <= data_pre_lim[OWIDTH - 1:0];
    end
    else if (TYPE == "ROUND")
      $error("Function cannot round yet");
    else 
      $error("Invalid TYPE parameter. Should be TRUNC, LIMIT, ROUND");
  end
end

assign data_o = data; 

endmodule // fir_ram_out_processor
