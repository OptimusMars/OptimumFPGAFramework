// Mixed Width Dual port Ram
module dpmram #(
  parameter FDWIDTH   = 32                    , // First Data Width
  parameter FAWIDTH   = 8                     , // First Adderss Width
  parameter SDWIDTH   = 16                    , // Second Data Width
  // (SDWIDTH/FDWIDTH) or (FDWIDTH/SDWIDTH) must be EVEN
  parameter REGOUT    = "Y"                   ,
  parameter INIT_FILE = ""                    ,
  parameter SAWIDTH   = (FDWIDTH == SDWIDTH) ?
  FAWIDTH : ((FDWIDTH > SDWIDTH) ?
  (FAWIDTH + $clog2(FDWIDTH/SDWIDTH)) :
  (FAWIDTH - $clog2(SDWIDTH/FDWIDTH)) )  // Don't assign this
) (
  input                      clka ,
  input                      wea  ,
  input        [FAWIDTH-1:0] addra,
  input  logic [FDWIDTH-1:0] dataa,
  output logic [FDWIDTH-1:0] qa   ,
  //!
  input                      clkb ,
  input                      web  ,
  input        [SAWIDTH-1:0] addrb,
  input  logic [SDWIDTH-1:0] datab,
  output logic [SDWIDTH-1:0] qb
);

initial begin
  if(FDWIDTH > SDWIDTH) begin
    if(FDWIDTH % SDWIDTH != 0) $error("FDWIDTH must be even of SDWIDTH");
    if((FDWIDTH / SDWIDTH) % 2 != 0) $error("FDWIDTH must be even of SDWIDTH with multiple of 2");
  end
  else begin 
    if(SDWIDTH % FDWIDTH != 0) $error("SDWIDTH must be even of FDWIDTH");
    if((SDWIDTH / FDWIDTH) % 2 != 0) $error("SDWIDTH must be even of FDWIDTH with multiple of 2");
  end  
  if(FDWIDTH * (1 << FAWIDTH) != SDWIDTH * (1<< SAWIDTH)) 
    $error("Write and Read port have different capacity");
end

genvar i;
generate if (FDWIDTH != SDWIDTH) begin
  localparam DEPTH    = FDWIDTH > SDWIDTH ? (1 << FAWIDTH) : (1 << SAWIDTH);
  localparam EVENESS  = FDWIDTH > SDWIDTH ? FDWIDTH/SDWIDTH : SDWIDTH/FDWIDTH;
  localparam LOAWIDTH = $clog2(EVENESS);
  localparam DWIDTH	  = FDWIDTH > SDWIDTH ? SDWIDTH : FDWIDTH;

  localparam AWIDTH	  = FDWIDTH > SDWIDTH ? FAWIDTH : SAWIDTH;
  
  initial if (INIT_FILE != "") $readmemh(INIT_FILE, mem);

  logic [AWIDTH-1:0] addr_hi;
  logic [LOAWIDTH-1:0] addr_lo; 
  if (FDWIDTH > SDWIDTH) begin
    assign addr_hi = addrb;
    assign addr_lo = addrb[LOAWIDTH-1:0];
    logic [FDWIDTH-1:0] qb_pre_mux;
    for (i = 0; i < EVENESS; i++) begin
      wire web_sel = web && addr_lo == LOAWIDTH'(i);
      dpram #(
        .DWIDTH    (DWIDTH),
        .AWIDTH    (AWIDTH),
        .REGOUT    (REGOUT),
        .INIT_FILE (INIT_FILE)
      ) dpram_instance (
        .clka  (clka),
        .wea   (wea),
        .addra (addra),
        .dataa (dataa[i*DWIDTH +: DWIDTH]),
        .qa    (qa[i*DWIDTH +: DWIDTH]),
        .clkb  (clkb),
        .web   (web_sel),
        .addrb (addr_hi),
        .datab (datab),
        .qb    (qb_pre_mux[i*DWIDTH +: DWIDTH])
      );  
    end  
    mux #(
      .DWIDTH (DWIDTH),
      .INPUTS (EVENESS)
    ) mux_inst (
  	  .data (qb_pre_mux),
      .sel  (addr_lo),
      .q    (qb)
    );
  end else begin
    assign addr_hi = addra;
    assign addr_lo = addra[LOAWIDTH-1:0];
    logic [SDWIDTH-1:0] qa_pre_mux;
    for (i = 0; i < EVENESS; i++) begin
      wire wea_sel = wea && addr_lo == LOAWIDTH'(i);
      dpram #(
        .DWIDTH    (DWIDTH),
        .AWIDTH    (AWIDTH),
        .REGOUT    (REGOUT),
        .INIT_FILE (INIT_FILE)
      ) dpram_instance (
        .clka  (clka),
        .wea   (wea_sel),
        .addra (addr_hi),
        .dataa (dataa),
        .qa    (qa_pre_mux[i*DWIDTH +: DWIDTH]),
        .clkb  (clkb),
        .web   (web),
        .addrb (addrb),
        .datab (datab[i*DWIDTH +: DWIDTH]),
        .qb    (qb[i*DWIDTH +: DWIDTH])
      );  
    end  
    mux #(
      .DWIDTH (DWIDTH),
      .INPUTS (EVENESS)
    ) mux_inst (
  	  .data (qa_pre_mux),
      .sel  (addr_lo),
      .q    (qa)
    );
  end
end else begin 
  dpram #(
    .DWIDTH     (SDWIDTH),
    .AWIDTH     (SAWIDTH),
    .REGOUT     (REGOUT),
    .INIT_FILE  (INIT_FILE)
  ) dpram_instance (
    .clka       (clka),
    .wea        (wea),
    .addra      (addra),
    .dataa      (dataa),
    .qa         (qa),
    .clkb       (clkb),
    .web        (web),
    .addrb      (addrb),
    .datab      (datab),
    .qb         (qb)
  );
end endgenerate

endmodule