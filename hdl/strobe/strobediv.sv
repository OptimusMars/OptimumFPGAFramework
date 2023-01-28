// Strobe divisor module
module strobediv
#(
  parameter DIV_WIDTH = 10    // Divisor width
)
(
  input                   clk,
  input                   rst,
  input                   stri,     
  input [DIV_WIDTH - 1:0] div,    // Strobe integer divisor, 
  output logic            stro,
  output logic            stro_div
);

logic                   strobe_en;
logic                   stri_d = '0;
logic [DIV_WIDTH - 1:0] cnt_div;

always_ff @ (posedge clk or posedge rst)
  if (rst) strobe_en <= '0;
  else if (cnt_div == div && stri) strobe_en <= '1;
  else if (stri) strobe_en <= '0;

always_ff @ (posedge clk or posedge rst)
  if (rst) cnt_div <= '0;
  else if (cnt_div == div && stri) cnt_div <= '0;
  else if (stri) cnt_div <= cnt_div + 1'b1;

always_ff @ (posedge clk) stri_d <= stri;

always_comb begin
  stro <= stri_d;
  stro_div <= stri_d && strobe_en;
end

endmodule // strobe_div