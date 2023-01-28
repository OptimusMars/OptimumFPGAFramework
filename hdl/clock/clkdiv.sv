// Clock divisor module
module clkdiv
#(
  parameter string GEN_BLOCK = "YES",
  parameter DIV_MAX = 8     // Maximum divisor
)
(
  input                         clk,
  input                         rst, 
  input [$clog2(DIV_MAX) - 1:0] div,
  output                        clk_div
);

generate
if(GEN_BLOCK == "YES") begin

  logic clk_div_r;
  logic [$clog2(DIV_MAX) - 1:0] cnt_div;
  wire equal_cnt = (cnt_div == div - 1) ? '1 : '0;
  wire equal_zero = (div == 0) ? '1 : '0;

  always_ff @ (posedge clk, posedge rst)
    if(rst) cnt_div <= '0;
    else if(equal_cnt) cnt_div <= '0;
    else cnt_div <= cnt_div + 1'b1;

  always_ff @ (posedge clk, posedge rst)
    if(rst) clk_div_r <= '0;
    else if(equal_cnt) clk_div_r <= ~clk_div_r;

  assign clk_div = equal_zero ? clk : clk_div_r;

end
else
  assign clk_div = '0;
endgenerate

endmodule