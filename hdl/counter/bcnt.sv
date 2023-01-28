// Binary counter
module bcnt
#(
  parameter         MAX       = 8,
  parameter         START     = 0,
  parameter         BEHAVIOR  = "SATURATE",    // or "ROLL"
  parameter         WIDTH     = $clog2(MAX)
)
(
  input                     clk,
  input                     aclr,
  input                     sclr = '0,
  input                     ena = '1,
  input                     load = '0,
  input logic [WIDTH-1:0]   data = '0,
  input                     dir = '1,
  input                     enmax = '0,
  input logic [WIDTH-1:0]   max = '0,
  output logic              ovf,
  output logic [WIDTH-1:0]  q
);

localparam START_ = (MAX > START) ? START : MAX;

logic [WIDTH-1:0] max_int;
assign max_int = enmax ? max : WIDTH'(MAX);
assign ovf = dir ? q == max_int : q == '0;

always_ff @ (posedge clk, posedge aclr) begin
  if (aclr)
    q <= WIDTH'(START_);
  else if (sclr)
    q <= WIDTH'(START_);
  else if (load)
    q <= data;
  else if (ena) begin
    if (BEHAVIOR == "SATURATE") begin
      if(ovf) q <= q;
      else q <= dir ? q + 1'b1 : q - 1'b1;
    end
    else if (BEHAVIOR == "ROLL") begin
      if(ovf) q <= dir ? '0 : max_int;
      else q <= dir ? q + 1'b1 : q - 1'b1;
    end  
  end
end

endmodule
