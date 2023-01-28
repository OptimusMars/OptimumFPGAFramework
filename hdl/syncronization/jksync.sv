// Syncronization edged signals with jkff
module jksync
(
  input   clki,   // syncronization clock input
  input   clko,   // syncronization clock
  input   rst,    // arst
  input   d,      // edge signal to be syncronized
  output  q       // edge syncronized signal
);

parameter LEN = 3;   

initial if (LEN < 2)
  $error("LEN must be greater than 1");

logic jkq;
logic reset_latch;

jkl jk0 (.j(d), .k(q), .q(jkq));

logic [LEN - 1:0] sync_reg;
logic sync_reg_d;
// Sync chain
always_ff @(posedge clko, posedge rst)
  if(rst) sync_reg <= '0;
  else sync_reg <= { sync_reg[LEN - 2:0], latch };

always_ff @(posedge clko, posedge rst)
  if(rst) sync_reg_d <= '0;
  else sync_reg_d <= sync_reg[LEN - 1];

// Posedge detection
assign q = ~sync_reg_d && sync_reg[LEN - 1];

endmodule