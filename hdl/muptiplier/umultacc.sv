module umultacc
#(
  parameter AWIDTH = 8,
  parameter BWIDTH = 8,
  parameter OWIDTH = AWIDTH + BWIDTH + 1   
)
(
  input wire                clk    = '0, 
  input wire                aclr   = '0, 
  input wire                clken  = '1,
  
  input logic [AWIDTH-1:0]  da, 
  input logic [BWIDTH-1:0]  db,
  output logic [OWIDTH-1:0] out
  
);

logic [AWIDTH-1:0]  dar; 
logic [BWIDTH-1:0]  dbr;
logic [OWIDTH-2:0]  multr;

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
