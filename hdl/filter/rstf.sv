module rstf
#(
  parameter LEN = 3
) 
(
  input   clk,        // Input clock
  input   rst,        // Reset to be syncronized
  output  rsto        // Syncronized reset signal
);

logic [LEN-1:0] rst_reg /* synthesis preserve */;

always_ff @(posedge clk or posedge rst)
  if (rst) rst_reg <= '0;
  else rst_reg <= {1'b1, rst_reg[LEN-1:1]};

assign rsto = !rst_reg[0];

endmodule