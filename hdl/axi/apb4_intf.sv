interface apb4_intf #(
    parameter DWIDTH = 32,
    parameter AWIDTH = 32
  );
  logic                psel   ;
  logic                penable;
  logic                pwrite ;
  logic [         2:0] pprot  ;
  logic [  AWIDTH-1:0] paddr  ;
  logic [  DWIDTH-1:0] pwdata ;
  logic [DWIDTH/8-1:0] pstrb  ;

  // Response
  logic [DWIDTH-1:0] prdata ;
  logic              pready ;
  logic              pslverr;

  modport host (
    output psel,
    output penable,
    output pwrite,
    output pprot,
    output paddr,
    output pwdata,
    output pstrb,

    input prdata,
    input pready,
    input pslverr
  );

  modport agent (
    input psel,
    input penable,
    input pwrite,
    input pprot,
    input paddr,
    input pwdata,
    input pstrb,

    output prdata,
    output pready,
    output pslverr
  );
endinterface
