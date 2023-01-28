module dcfifofsm #(
  parameter FUWIDTH   = 8,   // First port used width
  parameter SIZEF     = 256,   // First port size
  parameter SUWIDTH   = 7,   // Second 
  parameter SIZES     = 512
)
(
  input               rst, 
  // Write port
  input               clkw, 
  input               write,
  input [FUWIDTH-1:0] usedw,
  output              full,
  // Read port
  input               clkr,
  input               read,
  input [SUWIDTH-1:0] usedr,
  output              empty
);

localparam logic [FUWIDTH-1:0] USEDMAXF = FUWIDTH'(SIZEF-1);
localparam logic [SUWIDTH-1:0] USEDMAXS = SUWIDTH'(SIZES-1);

typedef enum logic [1:0] {ST_EMPTY = '0, ST_NOT_FULL, ST_FULL} fsm_t;

fsm_t wrfsm, rdfsm;

always_ff @ (posedge clkw, posedge rst) begin
  if(rst) begin
    wrfsm <= ST_EMPTY; 
  end
  else begin
    case(wrfsm)
      ST_EMPTY: begin
        if(usedw == 0 && write) wrfsm <= ST_NOT_FULL;
      end
      ST_NOT_FULL: begin
        if(usedw == USEDMAXF && write) wrfsm <= ST_FULL;
        else if (usedw == 0 && !write) wrfsm <= ST_EMPTY;
      end
      ST_FULL: begin
        if(usedw != 0) wrfsm <= ST_NOT_FULL;
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
        if(usedr != 0) rdfsm <= ST_NOT_FULL;
      end
      ST_NOT_FULL: begin
        if(usedr == 0) rdfsm <= ST_FULL;
        else if (usedr == 1 && read) rdfsm <= ST_EMPTY;
      end
      ST_FULL: begin
        if(usedr != 0) rdfsm <= ST_NOT_FULL;
      end
      default: rdfsm <= ST_EMPTY;
    endcase
  end
end

assign full   = wrfsm == ST_FULL;
assign empty  = rdfsm == ST_EMPTY;

endmodule