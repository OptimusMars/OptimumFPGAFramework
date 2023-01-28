module smult
#(
  parameter AWIDTH = 8,
  parameter BWIDTH = 8,
  parameter PIPELINE = 1,
  parameter OWIDTH = AWIDTH + BWIDTH
)
(
  input wire                          clk = '0,
  input         signed  [AWIDTH-1:0]  a,
  input         signed  [BWIDTH-1:0]  b,
  output logic  signed  [OWIDTH-1:0]  out
);

generate
  if(PIPELINE == 0)
    assign out = a * b;
  else if(PIPELINE == 1) begin
    always_ff @ (posedge clk) out <= a * b;
  end
  else if (PIPELINE == 2) begin
    logic signed [AWIDTH-1:0] ar;
    logic signed [BWIDTH-1:0] br;
    always_ff @ (posedge clk) begin
      ar <= a;
      br <= b;
      out <= ar * br;
    end
  end
  else
    $fatal("PIPELINE must be 0,1,2");
  
endgenerate

endmodule