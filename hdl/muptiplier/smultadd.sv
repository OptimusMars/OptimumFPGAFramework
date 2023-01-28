module smultadd
#(
  parameter DWIDTH = 16
)
(
  input clk, aclr, ena,
  input signed [DWIDTH-1:0] da, db, dc, dd,
  
  output logic signed [DWIDTH*2:0] out
);

logic signed [DWIDTH-1:0] dar, dbr, dcr, ddr;
logic signed [DWIDTH*2-1:0] m0r, m1r;

always_ff @ (posedge clk or posedge aclr) begin
  if (aclr) begin
    dar     <= '0;
    dbr     <= '0;
    dcr     <= '0;
    ddr     <= '0;
    m0r     <= '0;
    m1r     <= '0;
    out     <= '0;
  end
  else begin
    if(ena) begin
      dar <= da;
      dbr <= db;
      dcr <= dc;
      ddr <= dd;
    end
    m0r <= dar * dbr;
    m1r <= dcr * ddr;
    out <= m0r + m1r;
  end
end

endmodule