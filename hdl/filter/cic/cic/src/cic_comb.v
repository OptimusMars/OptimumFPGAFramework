module cic_comb
#(
  parameter WIDTH = 64
)
(
  input                           clk_i,
  input                           clk_en_i,
  input                           reset_i,
  input signed [WIDTH-1:0]        data_i,
  output reg signed [WIDTH-1:0]   data_o
);

reg signed [WIDTH-1:0] prev_data;

always @(posedge clk_i or posedge reset_i) begin
  if(reset_i) begin
    data_o <= 0;
    prev_data <= 0;
  end
  else if(clk_en_i) begin
    data_o <= data_i - prev_data;
    prev_data <= data_i;
  end
end

endmodule