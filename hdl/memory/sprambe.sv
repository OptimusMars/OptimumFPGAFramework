module sprambe
#(
  parameter         DWIDTH      = 128,
  parameter         AWIDTH      = 4,
  parameter string  REGOUT      = "Y",
  parameter         INIT_FILE   = "", 
  parameter         BEWIDTH     = DWIDTH/8
)
(
  input                       clk,
  input                       we,
  input         [AWIDTH-1:0]  addr,
  input         [DWIDTH-1:0]  data,
  input         [BEWIDTH-1:0] be,
  output logic  [DWIDTH-1:0]  q 
  
);

initial begin
  if(DWIDTH % 8 != 0) $error("WDWIDTH must be even of 8");
end

localparam DEPTH = 1 << AWIDTH;

logic [BEWIDTH-1:0][7:0] mem[DEPTH-1:0];

initial if (INIT_FILE != "") $readmemh(INIT_FILE, mem);

always @ (posedge clk) begin
  for(int i = 0; i < BEWIDTH; i++) begin
    if(be[i] && we) mem[addr][i] <= data[i*8 +:8];
  end    
end

generate if (REGOUT == "Y") 
  always_ff @ (posedge clk) q <= mem[addr];
else
  assign q = mem[addr];
endgenerate
  
endmodule
