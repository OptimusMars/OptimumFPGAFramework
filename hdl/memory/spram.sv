module spram
#(
  parameter         DWIDTH      = 128,
  parameter         AWIDTH      = 2,
  parameter         REGOUT      = "Y",
  parameter         INIT_FILE   = "" 
)
(
  input                       clk,
  input                       we,
  input         [AWIDTH-1:0]  addr,
  input         [DWIDTH-1:0]  data,
  output logic  [DWIDTH-1:0]  q 
  
);

localparam DEPTH = 1 << AWIDTH;

logic [DWIDTH-1:0] mem [DEPTH];

initial if (INIT_FILE != "") $readmemh(INIT_FILE, mem);

always @ (posedge clk)
if (we) mem[addr] <= data;

generate if (REGOUT == "Y") begin
  always @ (posedge clk) 
    if (we) q <= data;
    else q <= mem[addr];  
end
else begin
  assign q = mem[addr];
end
endgenerate
  
endmodule
