module dprambe
#(
  parameter         DWIDTH      = 16,
  parameter         AWIDTH      = 16,
  parameter         REGOUT      = "Y",
  parameter         INIT_FILE   = "",
  parameter         BEWIDTH     = DWIDTH/8
)
(
  input                       clka,
  input                       wea, 
  input         [AWIDTH-1:0]  addra,
  input         [DWIDTH-1:0]  dataa,
  input         [BEWIDTH-1:0] bea,
  output logic  [DWIDTH-1:0]  qa,
  
  input                       clkb,
  input                       web,
  input         [AWIDTH-1:0]  addrb,  
  input         [DWIDTH-1:0]  datab,
  input         [BEWIDTH-1:0] beb,
  output logic  [DWIDTH-1:0]  qb
);
localparam DEPTH = 1<<AWIDTH;

initial begin
  if(DWIDTH % 8 != 0) $error("DWIDTH must be even of 8");
end

// Declare the RAM variable
logic [DWIDTH-1:0] mem[DEPTH] /* synthesis syn_ramstyle="block_ram" */;

initial if (INIT_FILE != "") $readmemh(INIT_FILE, mem);

always_ff @ (posedge clka) begin
  for(int i = 0; i <= BEWIDTH; i++) begin
    if (bea[i] && wea) mem[addra/8 + i*8 +:8] <= dataa[i*8 +:8];
  end
end

always_ff @ (posedge clkb) begin
  for(int i = 0; i <= BEWIDTH; i++) begin
    if (beb[i] && web) mem[addrb/8 + i*8 +:8] <= datab[i*8 +:8];
  end
end

generate if (REGOUT == "Y") begin 
  always_ff @ (posedge clka) qa <= mem[addra];
  always_ff @ (posedge clkb) qb <= mem[addrb];
end else begin
  assign qa = mem[addra];
  assign qb = mem[addrb];
end endgenerate

endmodule