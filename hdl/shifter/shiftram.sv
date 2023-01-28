module shiftram
#(
  parameter DWIDTH  = 16,
  parameter DEPTH   = 256
)
(
  input                 clk, 
  input                 rst,
  input                 shift,
  input   [DWIDTH-1:0]  d,
  output  [DWIDTH-1:0]  q
);

localparam AWIDTH = $clog2(DEPTH);

logic [AWIDTH-1:0] wrcnt;
logic [AWIDTH-1:0] rdcnt;

dpram #(
  .DWIDTH   (DWIDTH),
  .AWIDTH   (AWIDTH)
) dpram_instance (
  .clka   (clk),
  .wea    (shift),
  .addra  (wrcnt),
  .dataa  (d),
  .qa     (),
  .clkb   (clk),
  .web    ('0),
  .addrb  (rdcnt),
  .datab  ('0),
  .qb     (q)
);

bcnt #(
  .MAX      (DEPTH-1),
  .START    (0),
  .BEHAVIOR ("ROLL"),
  .WIDTH    (AWIDTH)
) bcnt0 (
  .clk  (clk),
  .aclr (rst),
  .ena  (shift),
  .load ('0),
  .data ('0),
  .dir  ('1),
  .ovf  (),
  .q    (wrcnt)
);

bcnt #(
  .MAX      (DEPTH-1),
  .START    (1),
  .BEHAVIOR ("ROLL"),
  .WIDTH    (AWIDTH)
) bcnt1 (
  .clk  (clk),
  .aclr (rst),
  .ena  (shift),
  .load ('0),
  .data ('0),
  .dir  ('1),
  .ovf  (),
  .q    (rdcnt)
);


endmodule
