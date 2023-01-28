// Active low reset filter 
module rstnf
#(
  parameter LEN = 3
) 
(
  input     clk,        // Syncronization clock
  input     enable,     // Enable signal
  input     rstn,       // Active low reset signal to be syncronized
  output    rstno       // Syncronized reset
);

logic [LEN-1:0] rstn_reg /* synthesis preserve */;

always_ff @(posedge clk or negedge rstn)
  if (!rstn) rstn_reg <= '0;
  else rstn_reg <= { enable, rstn_reg[LEN-1:1] };

assign rstno = rstn_reg[0];

endmodule