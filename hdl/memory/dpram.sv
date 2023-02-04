module dpram
#(
  parameter         DWIDTH      = 16,
  parameter         AWIDTH      = 10,
  parameter         REGOUT      = "Y",
  parameter         INIT_FILE   = ""
)
(
  input                       clka,
  input                       wea, 
  input         [AWIDTH-1:0]  addra,
  input  logic  [DWIDTH-1:0]  dataa,
  output logic  [DWIDTH-1:0]  qa,
  
  input                       clkb,
  input                       web,
  input         [AWIDTH-1:0]  addrb,  
  input  logic  [DWIDTH-1:0]  datab,
  output logic  [DWIDTH-1:0]  qb
);
localparam DEPTH = 1 << AWIDTH;

logic [DWIDTH-1:0] mem[DEPTH-1:0];

initial if (INIT_FILE != "") $readmemh(INIT_FILE, mem);

always @ (posedge clka)
  if (wea) mem[addra] <= dataa;

always @ (posedge clkb)
  if (web) mem[addrb] <= datab;

generate if (REGOUT == "Y") begin
  always @ (posedge clka) qa <= mem[addra];
  always @ (posedge clkb) qb <= mem[addrb];  
end
else begin
  assign qa = mem[addra];
  assign qb = mem[addrb];
end
endgenerate

endmodule
