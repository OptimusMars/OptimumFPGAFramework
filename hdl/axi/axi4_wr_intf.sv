interface axi4_wr_intf #(
    parameter DWIDTH = 512,
    parameter AWIDTH = 32,
    parameter IDWIDTH = 4
  );
  logic [ IDWIDTH-1:0] aid   ;
  logic [  AWIDTH-1:0] aaddr ;
  logic [         7:0] alen  ;
  logic [         2:0] asize ;
  logic [         1:0] aburst;
  logic [         2:0] aprot ;
  logic [         3:0] acache;
  logic [         3:0] auser ;
  logic                avalid;
  logic                aready;
  
  logic [  DWIDTH-1:0] data  ;
  logic [DWIDTH/8-1:0] strb  ;
  logic                last  ;
  logic                valid ;
  logic                ready ;

  logic [         1:0] resp  ;
  logic                valid ;
  logic                ready ;

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
    output data  ,
    output strb  ,
    output last  ,
    output valid ,
    input  ready ,
    //!
    input  resp  ,
    input  valid ,
    output ready 
  );

  modport agent (
    input   aid    ,
    input   aaddr  ,
    input   alen   ,
    input   asize  ,
    input   aburst ,
    input   alock  ,
    input   acache ,
    input   aprot  ,
    input   aregion,
    input   aqos   ,
    input   avalid ,
    output  aready ,
    //!
    input   data  ,
    input   strb  ,
    input   last  ,
    input   valid ,
    output  ready ,
    //!
    output  resp  ,
    output  valid ,
    input   ready 
  );

endinterface : axi4_wr_intf

  