// Delay chain on registers
module delayreg
#(
  parameter WIDTH = 16,   // Width of signals
  parameter DELAY = 0     // Delay value
)
(
  input                         clk,
  input                         rst,
  input                         ena, 
  input   [WIDTH - 1:0]         data, 
  output  [WIDTH - 1:0]         delay, 
  output  [WIDTH*(DELAY+1)-1:0] taps
);

initial  if ( WIDTH == 0 ) $error("Width cannot be zero");

genvar i;
generate  if(DELAY == 0) begin
  assign delay    = data;
  assign taps     = data;
end else begin
  logic [WIDTH - 1:0] chain [DELAY - 1:0];    // Delay chain
      
  assign taps[0*WIDTH +: WIDTH] = data; // First tap its data
  assign delay = chain[DELAY - 1];    // Delayed data
  // Other taps delayed
  for (i = 1; i < DELAY + 1; i++) begin : taps_process
    assign taps[i*WIDTH +: WIDTH] = chain[i-1];
  end
  
  // Delay chain
  always_ff @ (posedge clk or posedge rst) begin
    for (int j = 0; j < DELAY; j++) begin
      if (rst) chain[j] <= '0;
      else if(ena) begin
        if(j == 0) chain[j] <= data;
        else chain[j] <= chain[j - 1];
      end
    end
  end
end endgenerate

endmodule