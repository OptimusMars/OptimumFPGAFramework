module reg_word_mux_layer #(
  parameter DWIDTH    = 32                 ,
  parameter WORDS_IN  = 32                 , // power of 2
  parameter SEL_NUM   = 2                  ,
  parameter N_TO_1    = 1 << SEL_NUM       ,
  parameter WORDS_OUT = WORDS_IN >> SEL_NUM
) (
  input                         clk ,
  input                         rst ,
  input                         ena ,
  input  [         SEL_NUM-1:0] sel ,
  input  [ DWIDTH*WORDS_IN-1:0] din ,
  output [DWIDTH*WORDS_OUT-1:0] dout
);

  genvar i;
  generate
    for (i = 0; i < WORDS_OUT; i++) begin
      reg_word_mux #(
        .SEL_NUM(SEL_NUM),
        .DWIDTH (DWIDTH )
      ) i_reg_word_mux (
        .clk (clk                                  ),
        .rst (rst                                  ),
        .ena (ena                                  ),
        .sel (sel                                  ),
        .din (din[DWIDTH*N_TO_1*i +: DWIDTH*N_TO_1]),
        .dout(dout[DWIDTH*i +: DWIDTH]             )
      );
    end
  endgenerate
endmodule