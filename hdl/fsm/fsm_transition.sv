interface fsm_transition #(int INPUTS = 8, STATES = 16) ();
  localparam STWIDTH = $clog2(STATES);
  localparam PRWIDTH = $clog2(INPUTS);
  
  typedef struct {
    logic [STWIDTH-1:0] next_state;
  } state_t;
  typedef struct {
    logic [PRWIDTH-1:0] next_state;
  } priority_t;

  logic       [INPUTS-1:0]  ine;
  priority_t  [INPUTS-1:0]  prio;
  state_t     [INPUTS-1:0]  next_states;
  
endinterface