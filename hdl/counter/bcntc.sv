// Binary counter for chained connection
module bcntc
#(
  parameter WIDTH = 8
)
(
  input                     clk,
  input                     aclr,
  input                     ena,
  input                     load,
  input logic [WIDTH-1:0]   data,
  input                     dir,
  output logic              ovf,
  output logic [WIDTH-1:0]  q
);

localparam MAX_VAL = 1 << WIDTH;

always_ff @ (posedge clk, posedge aclr) begin
  if (aclr) begin
    q <= '0;
    ovf <= '0;
  end
  else if (load) begin
    q <= data;
    ovf <= dir ? data == MAX_VAL-1 : data == WIDTH'(1);
  end
  else if (ena) begin
    ovf <= dir ? q == MAX_VAL-1 : q == WIDTH'(1);
    if(ovf) q <= dir ? '0 : MAX_VAL;
    else q <= dir ? q + 1'b1 : q - 1'b1;
  end
end
  
endmodule