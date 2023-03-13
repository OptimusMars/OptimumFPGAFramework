`timescale 1ns/1ns

`include "macro.svh"

module fsm #(parameter
	     INPUTS       = 8   ,
	type state_type_t = byte
) (
	input                clk  ,
	input                rst  ,
	input  [INPUTS-1:0]  in   ,
	input  state_table_t tbl  ,
	output state_type_t  state
);

localparam FSM_STATES = 256; 
localparam FSM_INPUTS = 256; 

`DECLARE_STATE_TRANS(state_type_t)
`DECLARE_STATE_TRANS(state_type_t)

function byte next_state (logic [FSM_INPUTS-1:0] sig, fsm_tr_`TYPE transition);
  byte prio_enabled [FSM_INPUTS-1:0];
  byte index [FSM_INPUTS-1:0];
  byte max_prio = 0;
  byte max_prio_index;

  for (int i = 0; i < FSM_INPUTS; i++) begin
    prio_enabled[i] = transition.prio[i] & transition.sige[i];
  end

  foreach (sig[i]) begin
    if(prio_enabled[i] > max_prio) begin
      max_prio = prio_enabled[i];
      max_prio_index = i;
    end
  end

  return transition.next[max_prio_index];
endfunction

always_ff @(posedge clk, posedge rst)
	if(rst) state <= '0;
	else state <= state_type_t'(next_state(in, tbl.trans[state]));
	
endmodule : fsm
