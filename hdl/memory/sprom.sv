module sprom
#(
  parameter         DWIDTH      = 128,
  parameter         AWIDTH      = 2,
  parameter         REGOUT      = "Y",  
  parameter         INIT_FILE   = "" 
)
(
  input                       clk,
  input         [AWIDTH-1:0]  addr,
  output logic  [DWIDTH-1:0]  q 
  
);

localparam DEPTH = 1 << AWIDTH;

logic [DWIDTH-1:0] mem [DEPTH-1:0];

initial if (INIT_FILE != "") $readmemh(INIT_FILE, mem);

generate if (REGOUT == "Y") begin
  always_ff @(posedge clk) q <= mem[addr];  
end
else begin
  assign q = mem[addr];  
end
endgenerate



endmodule