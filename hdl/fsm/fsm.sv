module fsm
	import fsm_pkg::*;
#(parameter
	     INPUTS       = 8   ,
	type state_type_t = byte
) (
	input                clk  ,
	input                rst  ,
	input  [INPUTS-1:0]  in   ,
	input  state_table_t tbl,
	output state_type_t  state
);

always_ff @(posedge clk, posedge rst)
	if(rst) state <= '0;
	else state <= state_type_t'(fsm_pkg::next_state(in, tbl.trans[byte'(state)]));
	
endmodule : fsm
