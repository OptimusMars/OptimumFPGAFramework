interface axi4_rd_intf (
  parameter DWIDTH = 64,
  parameter AWIDTH = 32,
  parameter IDWIDTH = 1
);
  //! AXI Master
  logic [IDWIDTH-1:0] aid    ;
  logic [ AWIDTH-1:0] aaddr  ;
  logic [        7:0] alen   ;
  logic [        2:0] asize  ;
  logic [        1:0] aburst ;
  logic               alock  ;
  logic [        3:0] acache ;
  logic [        2:0] aprot  ;
  logic [        3:0] aregion;
  logic [        3:0] aqos   ;
  logic               avalid ;
  logic               aready ;
  //!
  logic [IDWIDTH-1:0] rid   ;
  logic [ DWIDTH-1:0] rdata ;
  logic [        1:0] rresp ;
  logic               rlast ;
  logic               rvalid;
  logic               rready;

  modport host (
    output aid    ,
    output aaddr  ,
    output alen   ,
    output asize  ,
    output aburst ,
    output alock  ,
    output acache ,
    output aprot  ,
    output aregion,
    output aqos   ,
    output avalid ,
    input  aready ,
    //!
    input  rid   ,
    input  rdata ,
    input  rresp ,
    input  rlast ,
    input  rvalid,
    output rready
  );

  modport agent (
    input  aid    ,
    input  aaddr  ,
    input  alen   ,
    input  asize  ,
    input  aburst ,
    input  alock  ,
    input  acache ,
    input  aprot  ,
    input  aregion,
    input  aqos   ,
    input  avalid ,
    output aready ,
    //!
    output rid   ,
    output rdata ,
    output rresp ,
    output rlast ,
    output rvalid,
    input  rready
  );

endinterface : axi4_rd_intf
