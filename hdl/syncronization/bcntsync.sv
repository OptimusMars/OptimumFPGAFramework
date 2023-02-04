// Binary counter clock crossing
module bcntsync
#(
  parameter WIDTH = 16,
  parameter SYNCLEN = 3
)
(
  input   [WIDTH-1:0] bcnti,
  input               clko,
  output  [WIDTH-1:0] bcnto
);

logic [WIDTH-1:0] gcnt;
logic [WIDTH-1:0] gcnto;

bin2gray #(
  .DWIDTH(WIDTH)
) bin2gray_instance (
  .bin(bcnti),
  .gray(gcnt)
);

rsync #(
  .SYNC_LEN(SYNCLEN)
) rsync_instance [WIDTH-1:0] (
  .clk  (clko),
  .in   (gcnt),
  .out  (gcnto)
);

gray2bin #(
  .DWIDTH(WIDTH)
) gray2bin_instance (
  .gray   (gcnto),
  .bin    (bcnto)
);

endmodule