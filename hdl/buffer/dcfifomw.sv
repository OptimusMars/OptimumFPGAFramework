// Dual-clock FIFO mixed widths
module dcfifomw
#(
  parameter         FWIDTH      = 16,   // First data width
  parameter         SWIDTH      = 8,    // Second data width
  // (SWIDTH/FWIDTH) or (FWIDTH/SWIDTH) must be integer
  parameter         SIZE        = 32,   // Size of fifo in words of FWIDTH
  parameter         SYNCLEN     = 3,    // Sincronization latency
  parameter string  REGOUT      = "Y",
  parameter string  PROTECTED   = "Y",
  // locals
  parameter         FUWIDTH      = $clog2(SIZE),    // Don't assign this
  parameter         SUWIDTH       = (FWIDTH == SWIDTH) ? 
                                    FUWIDTH : ((FWIDTH > SWIDTH) ? 
                                    (FUWIDTH + (FWIDTH/SWIDTH)-1) : 
                                    (FUWIDTH - (SWIDTH/FWIDTH)+1) )  // Don't assign this
)
(
  input                             rst,
  input                             clkw,
  input         [FWIDTH-1:0]        data,
  input                             write,
  output logic                      full,
  output logic  [FUWIDTH-1:0]       usedw,
  
  input                             clkr,
  input                             read,
  output logic                      empty,
  output logic  [SUWIDTH-1:0]       usedr,
  output logic  [SWIDTH-1:0]        q
);

initial begin
  if(SIZE < 16) $error("Size of FIFO must be greater than 8");
  if(SIZE % 2) $error("Size must be multiple of 2");
end

initial begin
  if(FWIDTH > SWIDTH) begin
    if(FWIDTH % SWIDTH != 0) $error("FWIDTH must be even of SWIDTH");
  end
  else begin 
    if(SWIDTH % FWIDTH != 0) $error("SWIDTH must be even of FWIDTH");
  end
end

generate if (FWIDTH == SWIDTH) begin
  dcfifo #(
    .WIDTH      (FWIDTH),
    .SIZE       (SIZE),
    .SYNCLEN    (SYNCLEN),
    .REGOUT     (REGOUT),
    .PROTECTED  (PROTECTED)
  ) dcfifo0 (
    .rst      (rst),
    .clkw     (clkw),
    .data     (data),
    .write    (write),
    .full     (full),
    .usedw    (usedw),
    .clkr     (clkr),
    .read     (read),
    .empty    (empty),
    .usedr    (usedr),
    .q        (q)
  );
end 
else begin
  localparam EVENESS  = FWIDTH > SWIDTH ? FWIDTH/SWIDTH : SWIDTH/FWIDTH;
  localparam SIZES    = FWIDTH > SWIDTH ? SIZE*EVENESS : SIZE/EVENESS;
  
  logic               writep;
  logic               readp;
  
  if (PROTECTED == "Y") begin
    assign writep = write && !full;
    assign readp  = read && !empty;
  end
  else begin
    assign writep = write;
    assign readp  = read; 
  end

  logic [FUWIDTH-1:0] wraddr_first_clkw;
  logic [SUWIDTH-1:0] wraddr_second_clkw;
  logic [SUWIDTH-1:0] wraddr_second_clkr;
  
  logic [FUWIDTH-1:0] rdaddr_first_clkr;
  logic [FUWIDTH-1:0] rdaddr_first_clkw;
  logic [SUWIDTH-1:0] rdaddr_second_clkr;
  
  dpmram #(
    .FDWIDTH    (FWIDTH),
    .FAWIDTH    (FUWIDTH),
    .SDWIDTH    (SWIDTH),
    .REGOUT     (REGOUT)
  ) dpram (
    .clka   (clkw),
    .wea    (writep),
    .addra  (wraddr_first_clkw),
    .dataa  (data),
    .qa     (),
    .clkb   (clkr),
    .web    ('0),
    .addrb  (rdaddr_second_clkr),
    .datab  ('0),
    .qb     (q)
  );
      
  bcnts #(
    .MAX       (FWIDTH > SWIDTH ? SIZE-1 : SIZE-EVENESS),
    .STEP      (FWIDTH > SWIDTH ? 1 : EVENESS),
    .START     (0),
    .BEHAVIOR  ("ROLL")
  ) wraddr_first (
    .clk   (clkw),
    .aclr  (rst),
    .ena   (writep),
    .dir   ('1),
    .q     (wraddr_first_clkw)
  );
    
  bcnts #(
    .MAX      (FWIDTH > SWIDTH ? SIZES-EVENESS : SIZES-1),
    .STEP     (FWIDTH > SWIDTH ? EVENESS : 1),
    .START    ('0),
    .BEHAVIOR ("ROLL")
  ) wraddr_second (
    .clk  (clkw),
    .aclr (rst),
    .ena  (writep),
    .dir  ('1),
    .q    (wraddr_second_clkw)
  );
  
  bcnts #(
    .MAX       (FWIDTH > SWIDTH ? SIZES-EVENESS : SIZES-1),
    .STEP      (FWIDTH > SWIDTH ? EVENESS : 1),
    .START     (0),
    .BEHAVIOR  ("ROLL")
  ) rdaddr_first (
    .clk   (clkr),
    .aclr  (rst),
    .ena   (readp),
    .dir   ('1),
    .q     (rdaddr_second_clkr)
  );
    
  bcnts #(
    .MAX      (FWIDTH > SWIDTH ? SIZE-1 : SIZE-EVENESS),
    .STEP     (FWIDTH > SWIDTH ? 1 : EVENESS),
    .START    ('0),
    .BEHAVIOR ("ROLL")
  ) rdaddr_second (
    .clk  (clkr),
    .aclr (rst),
    .ena  (readp),
    .dir  ('1),
    .q    (rdaddr_first_clkr)
  );
    
  bcntsync #(.WIDTH(SUWIDTH), .SYNCLEN(SYNCLEN)) 
  sync0 (.bcnti(wraddr_second_clkw), .clko(clkr), .bcnto(wraddr_second_clkr));
  
  bcntsync #(.WIDTH(FUWIDTH), .SYNCLEN(SYNCLEN)) 
  sync1 (.bcnti(rdaddr_first_clkr), .clko(clkw), .bcnto(rdaddr_first_clkw));
  
  usedcalc #(.WIDTH(FUWIDTH)) usedcalc0 (
    .wrcnt  (wraddr_first_clkw),
    .rdcnt  (rdaddr_first_clkw),
    .used   (usedw)
  );

  usedcalc #(.WIDTH(SUWIDTH)) usedcalc1 (
    .wrcnt  (wraddr_second_clkr),
    .rdcnt  (rdaddr_second_clkr),
    .used   (usedr)
  );
  
  dcfifofsm #(.FUWIDTH(FUWIDTH), .SIZEF(SIZE), 
              .SUWIDTH(SUWIDTH), .SIZES(SIZES))
  fsm (
    .rst     (rst),
    .clkw    (clkw),
    .write   (writep),
    .usedw   (usedw),
    .full    (full),
    .clkr    (clkr),
    .read    (readp),
    .usedr   (usedr),
    .empty   (empty)
  );
         
end
endgenerate

endmodule