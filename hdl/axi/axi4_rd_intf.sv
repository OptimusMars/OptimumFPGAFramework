interface axi4_rd_intf (
  parameter DWIDTH = 64,
  parameter AWIDTH = 32,
  parameter IDWIDTH = 1
);
  //! AXI Master
  logic [IDWIDTH-1:0] id    ;
  logic [ AWIDTH-1:0] addr  ;
  logic [        7:0] len   ;
  logic [        2:0] size  ;
  logic [        1:0] burst ;
  logic               lock  ;
  logic [        3:0] cache ;
  logic [        2:0] prot  ;
  logic [        3:0] region;
  logic [        3:0] qos   ;
  logic               valid ;
  logic               ready ;
  //!
  logic [IDWIDTH-1:0] rid   ;
  logic [ DWIDTH-1:0] rdata ;
  logic [        1:0] rresp ;
  logic               rlast ;
  logic               rvalid;
  logic               rready;

  modport host (
    output id    ,
    output addr  ,
    output len   ,
    output size  ,
    output burst ,
    output lock  ,
    output cache ,
    output prot  ,
    output region,
    output qos   ,
    output valid ,
    input  ready ,
    //!
    input  rid   ,
    input  rdata ,
    input  rresp ,
    input  rlast ,
    input  rvalid,
    output rready
  );

  modport agent (
    input  id    ,
    input  addr  ,
    input  len   ,
    input  size  ,
    input  burst ,
    input  lock  ,
    input  cache ,
    input  prot  ,
    input  region,
    input  qos   ,
    input  valid ,
    output ready ,
    //!
    output rid   ,
    output rdata ,
    output rresp ,
    output rlast ,
    output rvalid,
    input  rready
  );

endinterface : axi4_rd_intf
