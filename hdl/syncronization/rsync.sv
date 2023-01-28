// Syncronization chain for level signals
module rsync 
#(
  parameter SYNC_LEN = 3
)
(
  input   clk,     // syncronization clock
  input   in,   // level signal to be syncronized
  output  out    // syncronized signal
);
   
initial begin
  if (SYNC_LEN < 2) $error("SYNC_LEN must be greater than 1");
end

logic [SYNC_LEN - 1:0] registers;

always_ff @(posedge clk)
  registers <= { registers[SYNC_LEN - 2:0], in };

assign out = registers[SYNC_LEN - 1]; 

endmodule