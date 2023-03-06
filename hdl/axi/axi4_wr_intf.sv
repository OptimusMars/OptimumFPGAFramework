interface axi4_wr_intf #(
    parameter DWIDTH = 512,
    parameter AWIDTH = 32,
    parameter IDWIDTH = 4
  );
  logic [ IDWIDTH-1:0] id   ;
  logic [  AWIDTH-1:0] addr ;
  logic [         7:0] len  ;
  logic [         2:0] size ;
  logic [         1:0] burst;
  logic [         2:0] prot ;
  logic [         3:0] cache;
  logic [         3:0] user ;
  logic                valid;
  logic                ready;
  
  logic [  DWIDTH-1:0] data  ;
  logic [DWIDTH/8-1:0] strb  ;
  logic                last  ;
  logic                valid ;
  logic                ready ;

  logic [         1:0] resp  ;
  logic                valid ;
  logic                ready ;

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
    input   id    ,
    input   addr  ,
    input   len   ,
    input   size  ,
    input   burst ,
    input   lock  ,
    input   cache ,
    input   prot  ,
    input   region,
    input   qos   ,
    input   valid ,
    output  ready ,
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

  