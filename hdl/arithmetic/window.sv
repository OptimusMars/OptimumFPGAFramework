// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module window #(
  parameter DWIDTH  = 16              ,
  parameter SAMPLES = 8               ,
  parameter ACWIDTH = SAMPLES + DWIDTH
) (
  input                       clk_i  ,
  input                       rst_i  ,
  input                       sclr_i ,
  input                       dval_i ,
  input  signed [ DWIDTH-1:0] data_i ,
  output signed [ACWIDTH-1:0] mean_o
);

reg  signed [ACWIDTH-1:0] accum    ;
wire signed [ DWIDTH-1:0] data_first;

delayreg #(.WIDTH(DWIDTH), .DELAY(SAMPLES)) i_delayreg (
  .clk  (clk_i          ),
  .rst  (rst_i || sclr_i),
  .ena  (dval_i         ),
  .data (data_i         ),
  .delay(data_first     )
);

always @ (posedge clk_i or posedge rst_i)
  if (rst_i) accum <= 0;
  if (sclr_i) accum <= 0;
  else if (dval_i) accum <= accum + (data_i - data_first);
  
assign mean_o = accum >>> SAMPLES;

endmodule 