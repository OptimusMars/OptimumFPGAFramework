// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fifo_rd_dconv #(
  parameter FIFO_DWIDTH = 64,
  parameter OUT_DWIDTH  = 16,
  parameter PIPELINE    = 1
) (
  input                          clk       ,
  input                          rst       ,
  //! FIFO read interface (normal fifo)
  input        [FIFO_DWIDTH-1:0] fifo_dout ,
  output logic                   fifo_read ,
  input                          fifo_empty,
  //! Converted DWIDTH
  output logic [ OUT_DWIDTH-1:0] conv_dout ,
  output logic                   conv_dval ,
  input                          conv_read ,
  output logic                   conv_empty
);

`define MAX(FIRST, SECOND) (((FIRST) > (SECOND)) ? (FIRST) : (SECOND))
`define MIN(FIRST, SECOND) (((FIRST) > (SECOND)) ? (SECOND) : (FIRST))

localparam MULTIPLE  = `MAX(FIFO_DWIDTH, OUT_DWIDTH)/`MIN(FIFO_DWIDTH, OUT_DWIDTH);
localparam PIPE_CNTW = $clog2(PIPELINE)                                           ;
localparam MULT_CNTW = $clog2(MULTIPLE)                                           ;

initial begin
  if(`MAX(FIFO_DWIDTH, OUT_DWIDTH) % `MIN(FIFO_DWIDTH, OUT_DWIDTH))
    $error("DWIDTH'S aren't multiple");  
  if (PIPELINE > 2) 
    $error("PIPELINE can't be greater than 2"); 
end

generate if (FIFO_DWIDTH > OUT_DWIDTH) begin

logic                  conv_read_d   ;
logic [ MULT_CNTW-1:0] data_sel      ;
logic [ MULT_CNTW-1:0] read_cnt      ;
logic                  read_cnt_zero ;
logic                  data_sel_zero ;
logic [OUT_DWIDTH-1:0] conv_dout_muxo;

delayreg #(.WIDTH(1), .DELAY(PIPELINE)) i0_delayreg (
  .clk  (clk        ),
  .rst  (rst        ),
  .ena  ('1         ),
  .data (conv_read  ),
  .delay(conv_read_d)
);

bcnts #(.MAX(MULTIPLE-1), .BEHAVIOR("ROLL")) i0_bcnts (
  .clk(clk), .aclr(rst), .ena(conv_read), .q(read_cnt) );

bcnts #(.MAX(MULTIPLE-1), .BEHAVIOR("ROLL")) i1_bcnts (
  .clk(clk), .aclr(rst), .ena(conv_read_d), .q(data_sel) );

mux #(.DWIDTH(FIFO_DWIDTH), .INPUTS(MULTIPLE)) 
i_mux (.data(fifo_dout), .sel(data_sel), .q(conv_dout_muxo));

always_comb begin
  read_cnt_zero = (read_cnt == '0);
  data_sel_zero = (data_sel == '0);
  fifo_read = conv_read && read_cnt_zero;
  conv_empty = fifo_empty && read_cnt_zero;
end

delayreg #(.WIDTH(1 + OUT_DWIDTH), .DELAY(PIPELINE)) i1_delayreg (
  .clk  (clk        ),
  .rst  (rst        ),
  .ena  ('1         ),
  .data ({conv_read_d, conv_dout_muxo}  ),
  .delay({conv_dval, conv_dout})
);

end 
else if (FIFO_DWIDTH < OUT_DWIDTH) begin
  $error("Unsupported parameter %s", `__LINE__);
end
else begin
  $error("Block is useless with this parameters");
end
endgenerate


endmodule