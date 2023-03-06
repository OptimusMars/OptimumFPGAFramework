package fsm_pkg;

localparam FSM_STATES = 256; 
localparam FSM_INPUTS = 256; 

typedef struct packed {
  logic [FSM_INPUTS-1:0] sige;
  byte  [FSM_INPUTS-1:0] prio;
  byte  [FSM_INPUTS-1:0] next;
} state_transition_t;

typedef struct packed {
  state_transition_t [FSM_STATES-1:0] trans; 
} state_table_t;

function byte next_state (logic [FSM_INPUTS-1:0] sig, state_transition_t transition);
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

endpackage : fsm_pkg