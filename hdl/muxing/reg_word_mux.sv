module reg_word_mux #(
  parameter DWIDTH   = 32          ,
  parameter SEL_NUM  = 2           ,
  parameter WORDS_IN = 1 << SEL_NUM
) (
  input                        clk ,
  input                        rst ,
  input                        ena ,
  input  [        SEL_NUM-1:0] sel ,
  input  [DWIDTH*WORDS_IN-1:0] din ,
  output [         DWIDTH-1:0] dout
);

  logic [DWIDTH-1:0] dout_c;
  logic [DWIDTH-1:0] dout  ;

  genvar i,j;
  generate
    for (i = 0; i < DWIDTH; i++) begin
      logic [WORDS_IN-1:0] data_t;
      for (j = 0; j < WORDS_IN; j++) begin
        assign data_t[j] = din[i+j*DWIDTH];
      end
      assign dout_c[i] = data_t[sel];
    end
  endgenerate

  always @(posedge clk, posedge rst)
    if (rst) dout <= 0;
    else if (ena) dout <= dout_c;

endmodule   