// Johnson counter
module jcnt
#(
  parameter WIDTH = 8
)
(
  input                     clk,
  input                     aclr,
  input                     ena,
  input                     dir,
  output logic              ovf,
  output logic [WIDTH-1:0]  q
);

logic q_;

shiftreg #(
  .WIDTH(WIDTH)
) shiftreg_instance (
  .clk    (clk),
  .aclr   (aclr),
  .ena    (ena),
  .load   ('0),
  .dload  ('0),
  .dir    (dir),
  .d      (~q_),
  .q      (q_),
  .qpar   (q)
);
  
endmodule