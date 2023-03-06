interface apb3_intf #(
  parameter DWIDTH = 32,
  parameter AWIDTH = 32
);
  // Command
  logic              psel   ;
  logic              penable;
  logic              pwrite ;
  logic [AWIDTH-1:0] paddr  ;
  logic [DWIDTH-1:0] pwdata ;

  // Response
  logic [DWIDTH-1:0] prdata ;
  logic              pready ;
  logic              pslverr;

  modport host (
    output psel,
    output penable,
    output pwrite,
    output paddr,
    output pwdata,

    input prdata,
    input pready,
    input pslverr
  );

  modport agent (
    input psel,
    input penable,
    input pwrite,
    input paddr,
    input pwdata,

    output prdata,
    output pready,
    output pslverr
  );
endinterface
