
`include "fsm_transition.sv"

module fsm
#(
  parameter INPUTS = 8,
  parameter STATES = 8,
  parameter STWIDTH = $clog2(STATES)
)
(
	input                                   clk,
	input                                   rst,
	input                  [INPUTS-1:0]     in,
	input  fsm_transition #(INPUTS, STATES) transitions [STATES-1:0],
	output logic           [STWIDTH-1:0]    state
);
	
function [STWIDTH-1:0] next_state(
  input logic [INPUTS-1:0] ins, 
  input fsm_transition #(INPUTS, STATES) transition
);

    
endfunction


	
endmodule : fsm
