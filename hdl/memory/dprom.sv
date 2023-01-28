module dprom
#(
  parameter         DWIDTH      = 128,
  parameter         AWIDTH      = 2,
  parameter string  REGOUT      = "Y",
  parameter string  INIT_FILE   = "" 
)
(
  input                       clka,
  input         [AWIDTH-1:0]  addra,
  output logic  [DWIDTH-1:0]  qa,
  
  input                       clkb,
  input         [AWIDTH-1:0]  addrb,
  output logic  [DWIDTH-1:0]  qb 
  
);

localparam DEPTH = 1 << AWIDTH;

logic [DWIDTH-1:0] mem [DEPTH] /* synthesis syn_ramstyle="block_ram" */;

initial if (INIT_FILE != "") $readmemh(INIT_FILE, mem);

generate if (REGOUT == "Y") begin
  always_ff @ (posedge clka) qa <= mem[addra];
  always_ff @ (posedge clkb) qb <= mem[addrb];  
end
else begin
  assign qa = mem[addra];
  assign qb = mem[addrb];  
end
endgenerate

endmodule