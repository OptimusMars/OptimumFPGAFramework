interface axi4lite_intf #(
    parameter DWIDTH = 32,
    parameter AWIDTH = 32
  );
  logic                awready;
  logic                awvalid;
  logic [AWIDTH-1:0]   awaddr ;
  logic [       2:0]   awprot ;
  //!
  logic                wready;
  logic                wvalid;
  logic [  DWIDTH-1:0] wdata ;
  logic [DWIDTH/8-1:0] wstrb ;
  //!
  logic                bready;
  logic                bvalid;
  logic [1:0]          bresp ;
  //!
  logic                arready;
  logic                arvalid;
  logic [AWIDTH-1:0]   araddr ;
  logic [       2:0]   arprot ;
  //!
  logic                rready;
  logic                rvalid;
  logic [DWIDTH-1:0]   rdata ;
  logic [       1:0]   rresp ;

  modport master (
    input   awready,
    output  awvalid,
    output  awaddr,
    output  awprot,

    input   wready,
    output  wvalid,
    output  wdata,
    output  wstrb,

    output  bready,
    input   bvalid,
    input   bresp,

    input   arready,
    output  arvalid,
    output  araddr,
    output  arprot,

    output  rready,
    input   rvalid,
    input   rdata,
    input   rresp
  );

  modport slave (
    output  awready,
    input   awvalid,
    input   awaddr,
    input   awprot,

    output  wready,
    input   wvalid,
    input   wdata,
    input   wstrb,

    input   bready,
    output  bvalid,
    output  bresp,

    output  arready,
    input   arvalid,
    input   araddr,
    input   arprot,

    input   rready,
    output  rvalid,
    output  rdata,
    output  rresp
  );
endinterface
