`timescale 1ns / 1ps

module dds
#(
  parameter WIDTH = 8     // Counter Width
)
(
  input               clk,
  input   [WIDTH-1:0] value,  // DDS value
  output              str     // Output strobe
);

logic [WIDTH:0] cnt = '0;

always_ff @(posedge clk)
  cnt <= {1'b0, cnt[WIDTH-1:0]} + value;

assign str = cnt[WIDTH];
    
endmodule
