//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_ram_mult_acc.sv
//-- created     : 14 марта 2020 г. : 12:58:16	
//-- author      : Martynov Ivan
//-- company     : Expert Electronix, Taganrog, Russia
//-- target      : [x] simulation  [x] synthesis
//-- technology  : [x] any
//-- tools & o/s : quartus 13.1 & windows 7
//-- dependency  :
//-------------------------------------------------------------------------------
//-- description : Multiplier with accumulator
//-- 
//--
//-------------------------------------------------------------------------------
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fir_ram_mult_acc
#(
  parameter DATA_WIDTH = 16,    // Data width
  parameter COEF_WIDTH = 16,    // Coefficient width
  parameter ACC_WIDTH = COEF_WIDTH + DATA_WIDTH // Accumulator width
)
(
  input                         clk_i,
  input                         rst_i,
  
  input                         clr_i,    // Accum clean
  
  input                         ena_i,
  input signed [DATA_WIDTH-1:0] data_i,   // data input
  input signed [COEF_WIDTH-1:0] coef_i,   // Coef input
  
  output signed [ACC_WIDTH-1:0] acc_o     // Accumulator
  
);

localparam MULT_WIDTH = COEF_WIDTH + DATA_WIDTH;

initial begin
  if ( ACC_WIDTH < COEF_WIDTH + DATA_WIDTH)
    $error("ACC_WIDTH must cannot be less than (COEF_WIDTH + DATA_WIDTH)");
end


logic signed [MULT_WIDTH - 1: 0] mult /* synthesis multstyle = "dsp" */;
logic signed [MULT_WIDTH - 1: 0] mult_r;
logic signed [MULT_WIDTH - 2: 0] mult_norm;   // Normalized multiplier output value
logic signed [ACC_WIDTH-1:0] accum;

assign mult = data_i * coef_i;      // Multiply data on coefficient

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) mult_r <= '0;
  else if (ena_i) mult_r <= mult;
end

logic ena_d;
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) ena_d <= '0;
  else ena_d <= ena_i;

assign mult_norm = $signed(mult_r[MULT_WIDTH - 2:0]);

assign acc_o = accum;

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) accum <= '0;
  else if (clr_i) accum <= '0;  
  else if (ena_d) accum <= accum + mult_norm;

endmodule // fir_ram_mult_acc
