module scfifo
#(
  parameter         WIDTH       = 16,
  parameter         SIZE        = 32,
  parameter string  REGOUT      = "Y",
  parameter string  PROTECTED   = "Y",
  parameter         UWIDTH      = $clog2(SIZE)
)
(
  input                             clk,
  input                             rst,
  input         [WIDTH-1:0]         data,
  input                             write,
  input                             read,
  output logic                      empty,
  output logic                      full,
  output logic  [UWIDTH-1:0]        used,
  output logic  [WIDTH-1:0]         q
);

logic [UWIDTH-1:0] wraddr;
logic [UWIDTH-1:0] rdaddr;

logic writep;
logic readp;
logic usedmax;

assign usedmax = used == SIZE-1;

generate if (PROTECTED == "Y") begin
  assign writep = write && !full;
  assign readp  = read && !empty;
end
else begin
  assign writep = write;
  assign readp  = read; 
end
endgenerate

dpram #(
  .DWIDTH (WIDTH),
  .AWIDTH (UWIDTH),
  .REGOUT (REGOUT)
) dpram0 (
  .clka   (clk),
  .wea    (writep),
  .addra  (wraddr),
  .dataa  (data),
  .qa     (),
  .clkb   (clk),
  .web    ('0),
  .addrb  (rdaddr),
  .datab  ('0),
  .qb     (q)
);

bcnt #(
  .MAX        (SIZE-1),
  .BEHAVIOR   ("ROLL"),
  .WIDTH      (UWIDTH)
) wraddrcnt (
  .clk    (clk),
  .aclr   (rst),
  .ena    (writep),
  .load   ('0),
  .data   ('0),
  .dir    ('1),
  .ovf    (),
  .q      (wraddr)
);

bcnt #(
  .MAX        (SIZE-1),
  .BEHAVIOR   ("SATURATE"),
  .WIDTH      (UWIDTH)
) rdaddrcnt (
  .clk    (clk),
  .aclr   (rst),
  .ena    (readp),
  .load   ('0),
  .data   ('0),
  .dir    ('1),
  .ovf    (),
  .q      (rdaddr)
);

logic used_ena;
logic used_dir;

assign used_ena = readp == writep ? '0 : readp | writep;
assign used_dir = writep && !readp;

bcnt #(
  .MAX        (SIZE-1),
  .BEHAVIOR   ("ROLL"),
  .WIDTH      (UWIDTH)
) usedcnt (
  .clk    (clk),
  .aclr   (rst),
  .ena    (used_ena),
  .load   ('0),
  .data   ('0),
  .dir    (used_dir),
  .ovf    (),
  .q      (rdaddr)
);

logic equal;
assign equal = rdaddr == wraddr;
assign empty = equal && !full;

always @(posedge clk, posedge rst) begin
  if (rst)
    full <= '0;
  else begin
    if(full) 
      full <= readp ? '0 : full;
    else begin
      full <= usedmax ? '1 : full;    
    end
  end
end
  
endmodule
