module gray2bin
#(
  parameter DWIDTH = 32
) 
(
  input  [DWIDTH-1:0] gray,
  output [DWIDTH-1:0] bin
);
  
genvar i;

generate for (i=0; i<DWIDTH; i=i+1) begin
  assign bin[i] = ^ gray[DWIDTH-1:i];
end
endgenerate

endmodule