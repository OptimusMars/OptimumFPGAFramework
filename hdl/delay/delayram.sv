// Delay chain on ram
module delayram
#(
  parameter WIDTH = 16,   // Width of signals
  parameter DELAY = 0     // Delay value
)
(
  input                         clk,
  input                         rst,
  input                         ena, 
  input   [WIDTH - 1:0]         data, 
  output  [WIDTH - 1:0]         delay
);

initial  if ( WIDTH == 0 ) $error("Width cannot be zero");

genvar i;
generate  if(DELAY == 0) begin
  assign delay = data;
  assign tap = data_i;
end else begin
  localparam RWIDTH = $clog2(DELAY);
  logic [RWIDTH-1:0] wrcnt;
  logic [RWIDTH-1:0] rdcnt;
  
  bcnt #(
    .MAX      (DELAY),
    .BEHAVIOR ("ROLL")
  ) bcnt0 (
    .clk  (clk),
    .aclr (rst),
    .ena  (ena),
    .load ('0),
    .data ('0),
    .dir  ('1),
    .q    (wrcnt)
  );
  
  bcnt #(
    .MAX      (DELAY),
    .START    (DELAY-1),
    .BEHAVIOR ("ROLL")
  ) bcnt1 (
    .clk  (clk),
    .aclr (rst),
    .ena  (ena),
    .load ('0),
    .data ('0),
    .dir  ('1),
    .q    (rdcnt)
  );  
  
  dpram #(
    .DWIDTH (WIDTH),
    .AWIDTH (RWIDTH),
    .REGIN  ("N"),
    .REGOUT ("Y")
  ) dpram_instance (
    .clka   (clk),
    .wea    (ena),
    .addra  (wrcnt),
    .dataa  (data),
    .qa     (),
    .clkb   (clk),
    .web    ('0),
    .addrb  (rdcnt),
    .datab  ('0),
    .qb     (delay)
  );
end endgenerate

endmodule