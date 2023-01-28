module muxpipe #(
  parameter DWIDTH    = 16,
  parameter INPUTS    = 4,
  parameter PIPELINE  = 0
) (
  input                       clk,
  input [DWIDTH*INPUTS-1:0]   data,
  input [$clog2(INPUTS)-1:0]  sel,
  output [DWIDTH-1:0]         q  
);
  
generate if (PIPELINE == 0) begin
  mux #(
    .DWIDTH (DWIDTH ),
    .INPUTS (INPUTS )
  ) u_mux (
  	.data (data ),
    .sel  (sel  ),
    .q    (q    )
  );
end else begin
  localparam STAGES = PIPELINE+1;
  

  
end
endgenerate


endmodule