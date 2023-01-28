module dcfifo
#(
  parameter         WIDTH       = 16,
  parameter         SIZE        = 32,
  parameter         SYNCLEN     = 3,
  parameter string  REGOUT      = "Y",
  parameter string  PROTECTED   = "Y",
  parameter         UWIDTH      = $clog2(SIZE)
)
(
  input                             rst,
  input                             clkw,
  input         [WIDTH-1:0]         data,
  input                             write,
  output logic                      full,
  output logic  [UWIDTH-1:0]        usedw,
  
  input                             clkr,
  input                             read,
  output logic                      empty,
  output logic  [UWIDTH-1:0]        usedr,
  output logic  [WIDTH-1:0]         q,
  
  output logic                      clkhalt
);

initial begin
  if(SIZE < 8) $error("Size of FIFO must be greater than 8");
end

localparam usedmax = UWIDTH'(SIZE-1);

logic [UWIDTH-1:0]  wraddr_clkw;
logic [UWIDTH-1:0]  wraddr_clkr;

logic [UWIDTH-1:0]  rdaddr_clkr;
logic [UWIDTH-1:0]  rdaddr_clkw;

logic               writep;
logic               readp;

generate if (PROTECTED == "Y") begin
  assign writep = write && !full;
  assign readp  = read && !empty;
end
else begin
  assign writep = write;
  assign readp  = read; 
end
endgenerate

bcnt #(
  .MAX        (SIZE-1),
  .BEHAVIOR   ("ROLL"),
  .WIDTH      (UWIDTH)
) wraddrcnt (
  .clk    (clkw),
  .aclr   (rst),
  .ena    (writep),
  .load   ('0),
  .data   ('0),
  .dir    ('1),
  .ovf    (),
  .q      (wraddr_clkw)
);

bcnt #(
  .MAX        (SIZE-1),
  .BEHAVIOR   ("SATURATE"),
  .WIDTH      (UWIDTH)
) rdaddrcnt (
  .clk    (clkr),
  .aclr   (rst),
  .ena    (readp),
  .load   ('0),
  .data   ('0),
  .dir    ('1),
  .ovf    (),
  .q      (rdaddr_clkr)
);

dpram #(
  .DWIDTH (WIDTH),
  .AWIDTH (UWIDTH),
  .REGOUT (REGOUT)
) dpram0 (
  .clka   (clkw),
  .wea    (writep),
  .addra  (wraddr_clkw),
  .dataa  (data),
  .qa     (),
  .clkb   (clkr),
  .web    ('0),
  .addrb  (rdaddr_clkr),
  .datab  ('0),
  .qb     (q)
);

bcntsync #(
  .WIDTH    (UWIDTH),
  .SYNCLEN  (SYNCLEN)
) bcntsync0 (
  .bcnti  (wraddr_clkw),
  .clko   (clkr),
  .bcnto  (wraddr_clkr)
);

bcntsync #(
  .WIDTH    (UWIDTH),
  .SYNCLEN  (SYNCLEN)
) bcntsync1 (
  .bcnti  (rdaddr_clkr),
  .clko   (clkw),
  .bcnto  (rdaddr_clkw)
);

typedef enum logic [1:0] {ST_EMPTY = '0, ST_NOT_FULL, ST_FULL} fsm_t;

fsm_t wrfsm, rdfsm;

logic [UWIDTH-1:0] usedw_;
logic [UWIDTH-1:0] usedr_;

usedcalc #(.WIDTH(UWIDTH)) usedcalc0 (
  .wrcnt  (wraddr_clkw),
  .rdcnt  (rdaddr_clkw),
  .used   (usedw_)
);

usedcalc #(.WIDTH(UWIDTH)) usedcalc1 (
  .wrcnt  (wraddr_clkr),
  .rdcnt  (rdaddr_clkr),
  .used   (usedr_)
);

always_ff @ (posedge clkw, posedge rst) begin
  if(rst) begin
    wrfsm <= ST_EMPTY; 
  end
  else begin
    case(wrfsm)
      ST_EMPTY: begin
        if(usedw_ == 0 && writep) wrfsm <= ST_NOT_FULL;
      end
      ST_NOT_FULL: begin
        if(usedw_ == usedmax && writep) wrfsm <= ST_FULL;
        else if (usedw_ == 0 && !writep) wrfsm <= ST_EMPTY;
      end
      ST_FULL: begin
        if(usedw_ != 0) wrfsm <= ST_NOT_FULL;
      end
      default: wrfsm <= ST_EMPTY;
    endcase
  end
end

always_ff @ (posedge clkr, posedge rst) begin
  if(rst) begin
    rdfsm <= ST_EMPTY; 
  end
  else begin
    case(rdfsm)
      ST_EMPTY: begin
        if(usedr_ != 0) rdfsm <= ST_NOT_FULL;
      end
      ST_NOT_FULL: begin
        if(usedr_ == 0) rdfsm <= ST_FULL;
        else if (usedr_ == 1 && readp) rdfsm <= ST_EMPTY;
      end
      ST_FULL: begin
        if(usedr_ != 0) rdfsm <= ST_NOT_FULL;
      end
      default: rdfsm <= ST_EMPTY;
    endcase
  end
end

assign full   = wrfsm == ST_FULL;
assign empty  = rdfsm == ST_EMPTY;
assign usedw  = usedw_;
assign usedr  = usedr_;

endmodule