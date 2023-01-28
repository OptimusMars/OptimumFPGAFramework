module smultacc
#(
  parameter AWIDTH = 8,
  parameter BWIDTH = 8,
  parameter OWIDTH = AWIDTH + BWIDTH + 1   
)
(
  input wire                        clk    = '0, 
  input wire                        aclr   = '0, 
  input wire                        clken  = '1,
  
  input logic signed  [AWIDTH-1:0]  da, 
  input logic signed  [BWIDTH-1:0]  db,
  output logic signed [OWIDTH-1:0]  out
  
);

logic signed [AWIDTH-1:0]  dar; 
logic signed [BWIDTH-1:0]  dbr;
logic signed [OWIDTH-2:0]  multr;

always @ (posedge clk or posedge aclr) begin
  if (aclr) begin
    dar   <= '0;
    dbr   <= '0;
    multr <= '0;
    out   <= '0;
  end
  else if (clken) begin
    dar   <= da;
    dbr   <= db;
    multr <= dar * dbr;
    out   <= multr + out;
  end
end

endmodule