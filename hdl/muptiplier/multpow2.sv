module multpow2 #(
  parameter AWIDTH = 8,
  parameter BWIDTH = 8,
  parameter PIPELINE = 1,
  parameter OWIDTH = AWIDTH + BWIDTH
) 
(
  input clk,    // Clock
  input ena, // Clock Enable
  
  input signed [AWIDTH-1:0] data,
  input signed [BWIDTH-1:0] datb,

  output signed [OWIDTH-1:0] dato
);

`include "../macro/macro.svh"
import mult_pkg::*




endmodule : multpow2