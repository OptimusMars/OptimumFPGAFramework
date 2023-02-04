// Binary counter with fixed step
module bcnts
#(
  parameter         MAX       = 8,
  parameter         STEP      = 1,
  parameter         START     = 0,
  parameter         BEHAVIOR  = "SATURATE",    // or "ROLL"
  parameter         WIDTH     = $clog2(MAX)
)
(
  input                     clk,
  input                     aclr,
  input                     ena,
  input                     dir,
  output logic              ovf,
  output logic [WIDTH-1:0]  q
);

initial if (MAX % STEP != 0) $error("MAX must be even of STEP");
initial if (START % STEP != 0) $error("MAX must be even of STEP");
initial if (START > MAX) $error("START must be less than START");

localparam logic [WIDTH-1:0] step_ = WIDTH'(STEP);
localparam logic [WIDTH-1:0] max_ = WIDTH'(MAX);

assign ovf = dir ? q == max_ : q == '0;

always_ff @ (posedge clk, posedge aclr) begin
  if (aclr)
    q <= WIDTH'(START);
  else if (ena) begin
    if (BEHAVIOR == "SATURATE") begin
      if(ovf) q <= q;
      else q <= dir ? q + step_ : q - step_;
    end
    else if (BEHAVIOR == "ROLL") begin
      if(ovf) q <= dir ? '0 : max_;
      else q <= dir ? q + step_ : q - step_;
    end  
  end
end
  
endmodule