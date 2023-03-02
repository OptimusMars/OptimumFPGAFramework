//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : sine_o value for testbenches
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : sine_tb.sv
//-- created     : 23 марта 2020 г. : 14:21:43	
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

module sine_tb
#(
  parameter DWIDTH      = 16,
  parameter PHASE_MAX   = 1024
)
(
  input                               clk_i,
  input                               rst_i,
  input                               clk_ena_i, 
  output logic signed [DWIDTH - 1:0]  sine_o,
  output logic signed [DWIDTH - 1:0]  cos_o
);

parameter real PI = 3.14159265358979323846;
localparam PHASE_WIDTH = $clog2(PHASE_MAX);
localparam MAX_VAL = (2**(DWIDTH-1)) - 1;

int phase;
real phase_real;
real sin_real;
real cos_real;

typedef logic signed [DWIDTH - 1:0] out_t;

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) phase <= '0;
  else if (clk_ena_i) begin 
    if(phase == PHASE_MAX-1) phase <= '0;
    else phase <= phase + 1'b1;
  end
end

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    phase_real <= 0.0;
    sin_real <= 0.0;
    cos_real <= 0.0;
    sine_o <= '0;
    cos_o <= '0;
  end
  else if (clk_ena_i) begin 
    phase_real <= (phase * 2 * PI)/PHASE_MAX;
    sin_real <= $sin(phase_real);
    cos_real <= $cos(phase_real);
    sine_o <= out_t'($floor(sin_real * MAX_VAL));
    cos_o <= out_t'($floor(cos_real * MAX_VAL));
  end
end


endmodule // sine_tb
