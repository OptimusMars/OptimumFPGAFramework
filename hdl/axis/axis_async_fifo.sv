`timescale 1ns / 1ps

//!AXI4-Stream asynchronous FIFO
module axis_async_fifo #(
  parameter SIZE        = 4096          ,
  parameter DWIDTH      = 8             , //!Width of AXI stream interfaces in bits
  parameter LAST_ENABLE = 1             , //! Propagate tlast signal
  parameter ID_ENABLE   = 0             , //! Propagate tid signal
  parameter ID_WIDTH    = 4             , //! tid signal width
  parameter DEST_ENABLE = 0             , //! Propagate tdest signal
  parameter DEST_WIDTH  = 4             , //! tdest signal width
  parameter USER_ENABLE = 1             , //! Propagate tuser signal
  parameter USER_WIDTH  = 1             , //! tuser signal width
  parameter KEEP_ENABLE = (DWIDTH>8)    , //! Propagate tkeep signal
  parameter KEEP_WIDTH  = ((DWIDTH+7)/8), //!tkeep signal width (words per cycle)
  parameter USED_WIDTH  = $clgo2(SIZE)
) (
  //! AXI input
  input  logic                  s_clk        ,
  input  logic                  s_rst        ,
  input  logic [    DWIDTH-1:0] s_axis_tdata ,
  input  logic [KEEP_WIDTH-1:0] s_axis_tkeep ,
  input  logic                  s_axis_tvalid,
  output logic                  s_axis_tready,
  input  logic                  s_axis_tlast ,
  input  logic [  ID_WIDTH-1:0] s_axis_tid   ,
  input  logic [DEST_WIDTH-1:0] s_axis_tdest ,
  input  logic [USER_WIDTH-1:0] s_axis_tuser ,
  //!AXI output
  input  logic                  m_clk        ,
  input  logic                  m_rst        ,
  output logic [    DWIDTH-1:0] m_axis_tdata ,
  output logic [KEEP_WIDTH-1:0] m_axis_tkeep ,
  output logic                  m_axis_tvalid,
  input  logic                  m_axis_tready,
  output logic                  m_axis_tlast ,
  output logic [  ID_WIDTH-1:0] m_axis_tid   ,
  output logic [DEST_WIDTH-1:0] m_axis_tdest ,
  output logic [USER_WIDTH-1:0] m_axis_tuser ,
  //!Status s_clk
  output logic                  fullw        ,
  output logic                  emptyw       ,
  output logic [USED_WIDTH-1:0] usedw        ,
  //!Status m_clk
  output logic                  fullr        ,
  output logic                  emptyr       ,
  output logic [USED_WIDTH-1:0] usedr
);

localparam KEEP_OFFSET = DWIDTH                                      ;
localparam LAST_OFFSET = KEEP_OFFSET + (KEEP_ENABLE ? KEEP_WIDTH : 0);
localparam ID_OFFSET   = LAST_OFFSET + (LAST_ENABLE ? 1          : 0);
localparam DEST_OFFSET = ID_OFFSET   + (ID_ENABLE   ? ID_WIDTH   : 0);
localparam USER_OFFSET = DEST_OFFSET + (DEST_ENABLE ? DEST_WIDTH : 0);
localparam WIDTH       = USER_OFFSET + (USER_ENABLE ? USER_WIDTH : 0);

logic [WIDTH-1:0] data;
logic [WIDTH-1:0] q;

always_comb begin
  data[DATA_WIDTH-1:0] = s_axis_tdata;
  if (KEEP_ENABLE) data[KEEP_OFFSET +: KEEP_WIDTH] = s_axis_tkeep;
  if (LAST_ENABLE) data[LAST_OFFSET]               = s_axis_tlast;
  if (ID_ENABLE)   data[ID_OFFSET   +: ID_WIDTH]   = s_axis_tid;
  if (DEST_ENABLE) data[DEST_OFFSET +: DEST_WIDTH] = s_axis_tdest;
  if (USER_ENABLE) data[USER_OFFSET +: USER_WIDTH] = s_axis_tuser;

  m_axis_tdata = q[DATA_WIDTH-1:0];
  m_axis_tkeep = KEEP_ENABLE ? q[KEEP_OFFSET +: KEEP_WIDTH] : '1;
  m_axis_tlast = LAST_ENABLE ? q[LAST_OFFSET] : 1'b1;
  m_axis_tid   = ID_ENABLE   ? q[ID_OFFSET +: ID_WIDTH] : '0;
  m_axis_tdest = DEST_ENABLE ? q[DEST_OFFSET +: DEST_WIDTH] : '0;
  m_axis_tuser = USER_ENABLE ? q[USER_OFFSET +: USER_WIDTH] : '0;

  s_axis_tready = !fullw;
end

rsync i_rsync (.clk(m_clk), .in(fullw), .out(fullr));
rsync i_rsync (.clk(s_clk), .in(emptyr), .out(emptyw));

dcfifo #(.WIDTH(WIDTH), .SIZE(DEPTH), .SYNCLEN(3)) i_dcfifo (
  .rst  (s_rst || m_rst    ),
  .clkw (s_clk             ),
  .data (data              ),
  .write(s_axis_tvalid     ),
  .full (fullw             ),
  .usedw(usedw             ),
  
  .clkr (m_clk             ),
  .read (m_axis_mm2s_tready),
  .empty(emptyr            ),
  .usedr(usedr             ),
  .q    (q                 )
);

endmodule