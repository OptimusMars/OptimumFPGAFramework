module pipelined_word_mux #(
  parameter DWIDTH          = 32                                      ,
  parameter WORDS_IN        = 16                                      , // power of 2
  parameter SEL_PER_LAYER   = 2                                       , // output layer may be less
  parameter BALANCE_SELECTS = 1'b1                                    , // adjust select latency to follow data?
  parameter SEL_NUM         = ((WORDS_IN <= 1) ? 1 : log2(WORDS_IN-1))
) (
  input                        clk ,
  input                        rst ,
  input                        ena ,
  input  [        SEL_NUM-1:0] sel ,
  input  [DWIDTH*WORDS_IN-1:0] din ,
  output [         DWIDTH-1:0] dout
);

genvar i;
generate
  if (SEL_NUM >= SEL_PER_LAYER) begin
    // knock out a full leaf layer
    logic [(WORDS_IN>>SEL_PER_LAYER)*DWIDTH-1:0] layer_dout;
    reg_word_mux_layer #(
      .DWIDTH  (DWIDTH       ),
      .WORDS_IN(WORDS_IN     ),
      .SEL_NUM (SEL_PER_LAYER)
    ) lyr (
      .clk (clk                   ),
      .rst (rst                   ),
      .ena (ena                   ),
      .sel (sel[SEL_PER_LAYER-1:0]),
      .din (din                   ),
      .dout(layer_dout            )
    );

    // deal with the select latency if it needs
    // to be balanced with the data
    logic [((SEL_NUM > SEL_PER_LAYER) ?
      (SEL_NUM-(1+SEL_PER_LAYER)) :
      0):0] next_sel;

    if (SEL_NUM > SEL_PER_LAYER) begin
      // some selects survive to next layer
      if (BALANCE_SELECTS) begin
        always @(posedge clk, posedge rst) begin
          if (rst) next_sel <= '0;
          else if (ena) next_sel <= sel [SEL_NUM-1:SEL_PER_LAYER];
        end
        else begin
          always @(*) next_sel = sel[SEL_NUM-1:SEL_PER_LAYER];
        end
      end
      else begin
        // all selects used - dummy
        always @(*) next_sel = '0;
      end
      // recurse on smaller problem
      pipelined_word_mux #(
        .DWIDTH         (DWIDTH                   ),
        .WORDS_IN       (WORDS_IN >> SEL_PER_LAYER),
        .SEL_PER_LAYER  (SEL_PER_LAYER            ),
        .BALANCE_SELECTS(BALANCE_SELECTS          )
      ) pp (
        .clk (clk       ),
        .rst (rst       ),
        .ena (ena       ),
        .sel (next_sel  ),
        .din (layer_dout),
        .dout(dout      )
      );
    end
    else if (WORDS_IN > 1) begin
      // Final mux isn't the full size
      reg_word_mux_layer #(
        .DWIDTH  (DWIDTH  ),
        .WORDS_IN(WORDS_IN),
        .SEL_NUM (SEL_NUM )
      ) lyr (
        .clk (clk ),
        .rst (rst ),
        .ena (ena ),
        .sel (sel ),
        .din (din ),
        .dout(dout)
      );
    end
    else begin
      // last word
      assign dout = din;
    end
endgenerate

endmodule