interface axi4_wr_intf #(
    parameter DWIDTH = 512,
    parameter AWIDTH = 32,
    parameter IDWIDTH = 4
  );
  logic [ IDWIDTH-1:0] awid   ;
  logic [  AWIDTH-1:0] awaddr ;
  logic [         7:0] awlen  ;
  logic [         2:0] awsize ;
  logic [         1:0] awburst;
  logic [         2:0] awprot ;
  logic [         3:0] awcache;
  logic [         3:0] awuser ;
  logic                awvalid;
  logic                awready;
  
  logic [  DWIDTH-1:0] wdata  ;
  logic [DWIDTH/8-1:0] wstrb  ;
  logic                wlast  ;
  logic                wvalid ;
  logic                wready ;

  logic [         1:0] bresp  ;
  logic                bvalid ;
  logic                bready ;

  modport host (
    output awid    ,
    output awaddr  ,
    output awlen   ,
    output awsize  ,
    output awburst ,
    output awlock  ,
    output awcache ,
    output awprot  ,
    output awregion,
    output awqos   ,
    output awvalid ,
    input  awready ,
    //!
    output wdata  ,
    output wstrb  ,
    output wlast  ,
    output wvalid ,
    input  wready ,
    //!
    input  bresp  ,
    input  bvalid ,
    output bready 
  );

  modport agent (
    input   awid    ,
    input   awaddr  ,
    input   awlen   ,
    input   awsize  ,
    input   awburst ,
    input   awlock  ,
    input   awcache ,
    input   awprot  ,
    input   awregion,
    input   awqos   ,
    input   awvalid ,
    output  awready ,
    //!
    input   wdata  ,
    input   wstrb  ,
    input   wlast  ,
    input   wvalid ,
    output  wready ,
    //!
    output  bresp  ,
    output  bvalid ,
    input   bready 
  );

endinterface : axi4_wr_intf

  