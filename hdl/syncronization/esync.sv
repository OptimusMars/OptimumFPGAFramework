// Syncronization chain for edge signals
module esync 
(
  input   rst,      // arst
  input   clki,     // syncronization clock input
  input   clko,     // syncronization clock
  input   in,       // edge signal to be syncronized
  output  out       // edge syncronized signal
);

parameter LEN = 3;   

initial
if (LEN < 2)
  $error("LEN must be greater than 2");

bit toggle;
  
always_ff @(posedge clki, posedge rst)
  if(rst) toggle <= '0;
  else if(in) toggle <= ~toggle;
    
bit [LEN - 1:0] sync_reg;
bit sync_reg_d;
// Sync chain
always_ff @(posedge clko, posedge rst)
  if(rst) sync_reg <= '0;
  else sync_reg <= { sync_reg[LEN - 2:0], toggle };

always_ff @(posedge clko, posedge rst)
  if(rst) sync_reg_d <= '0;
  else sync_reg_d <= sync_reg[LEN - 1];

// Posedge detection
assign out = sync_reg[LEN - 1] ^ sync_reg_d;

endmodule