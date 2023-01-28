module bin2gray
#(
  parameter DWIDTH = 32
) 
(
  input  [DWIDTH-1:0] bin,
  output [DWIDTH-1:0] gray
);

function [DWIDTH-1:0] binary2gray;
  input [DWIDTH-1:0] value;
  integer i;
begin 
  binary2gray[DWIDTH-1] = value[DWIDTH-1];
  for (i = DWIDTH-1; i > 0; i = i - 1)
    binary2gray[i - 1] = value[i] ^ value[i - 1];
end
endfunction

assign gray = binary2gray(bin);

endmodule