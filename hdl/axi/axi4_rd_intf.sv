interface axi4_rd_intf (
  parameter DWIDTH = 64,
  parameter AWIDTH = 32,
  parameter IDWIDTH = 1
);
  //! AXI Master
  logic [IDWIDTH-1:0] arid    ;
  logic [ AWIDTH-1:0] araddr  ;
  logic [        7:0] arlen   ;
  logic [        2:0] arsize  ;
  logic [        1:0] arburst ;
  logic               arlock  ;
  logic [        3:0] arcache ;
  logic [        2:0] arprot  ;
  logic [        3:0] arregion;
  logic [        3:0] arqos   ;
  logic               arvalid ;
  logic               arready ;
  //!
  logic [IDWIDTH-1:0] rid   ;
  logic [ DWIDTH-1:0] rdata ;
  logic [        1:0] rresp ;
  logic               rlast ;
  logic               rvalid;
  logic               rready;

  modport host (
    output arid    ,
    output araddr  ,
    output arlen   ,
    output arsize  ,
    output arburst ,
    output arlock  ,
    output arcache ,
    output arprot  ,
    output arregion,
    output arqos   ,
    output arvalid ,
    input  arready ,
    //!
    input  rid   ,
    input  rdata ,
    input  rresp ,
    input  rlast ,
    input  rvalid,
    output rready
  );

  modport agent (
    input  arid    ,
    input  araddr  ,
    input  arlen   ,
    input  arsize  ,
    input  arburst ,
    input  arlock  ,
    input  arcache ,
    input  arprot  ,
    input  arregion,
    input  arqos   ,
    input  arvalid ,
    output arready ,
    //!
    output rid   ,
    output rdata ,
    output rresp ,
    output rlast ,
    output rvalid,
    input  rready
  );

endinterface : axi4_rd_intf
