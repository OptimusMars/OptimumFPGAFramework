module shiftreg
#(
  parameter WIDTH = 8
)
(
  input               clk,
  input               aclr,
  input               ena,
  input               load,
  input [WIDTH-1:0]   dload,
  input               dir,
  input               d,
  output              q,
  output [WIDTH-1:0]  qpar
);

logic [WIDTH-1:0] shift;

assign qpar = shift;
assign q = dir ? shift[WIDTH-1] : shift[0]; 

initial begin
  if(WIDTH >= 2) $error("WIDTH must >= 2");
end

always_ff @(posedge clk, posedge aclr) 
  if (aclr)
    shift <= '0;
  else if (load)
    shift <= dload;
  else if (ena)
    shift <= dir ?  {shift[WIDTH-2:0], d} : 
                    {d, shift[WIDTH-1:1]}; 

endmodule