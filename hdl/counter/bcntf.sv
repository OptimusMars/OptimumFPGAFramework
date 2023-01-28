// Fast Binary counter
module bcntf
#(
  parameter WIDTH = 64,
  parameter WCHAN = 16
)
(
  input                     clk,
  input                     aclr,
  input                     ena,
  input                     load,
  input logic [WIDTH-1:0]   data,
  input                     dir,
  output logic              ovf,
  output logic [WIDTH-1:0]  q
);

localparam CHAN_REM = WIDTH%WCHAN;
localparam CHAN_CNT = WIDTH/WCHAN;


genvar i;
generate for (i = 0; i < CHAN_CNT; i++) begin
  bcntc #(.WIDTH(WCHAN)) 
  bcntc0 (
    .clk    (clk),
    .aclr   (aclr),
    .ena    (ena),
    .load   (load),
    .data   (data[WIDTH*i +:WIDTH]),
    .dir    (dir),
    .ovf    (ovf[i]),
    .q      (q[WIDTH*i +:WIDTH])
  );
end endgenerate

generate if (CHAN_REM != 0) begin
bcntc #(.WIDTH(CHAN_REM)) 
bcntc1 (
  .clk    (clk),
  .aclr   (aclr),
  .ena    (ena),
  .load   (load),
  .data   (data[WIDTH*CHAN_CNT +:CHAN_REM]),
  .dir    (dir),
  .ovf    (ovf[i]),
  .q      (q[WIDTH*CHAN_CNT +:CHAN_REM])
);    
end endgenerate

endmodule