module pulse #(parameter WIDTH = 2) (
  input        clk   ,
  input        ena   ,
  input        str   ,
  output logic pulseo
);

generate if (WIDTH == 0) begin
  assign pulseo = str;
end else begin

logic [$clog2(WIDTH)-1:0] cnt;
logic strm;
assign strm = str && ena;

always_ff @(posedge clk or posedge rst) begin
  if(rst) begin
    cnt    <= '0;
    pulseo <= '0;
  end else begin
    if(strm) begin
      pulseo <= '1;
      cnt    <= '0;
    end
    else if(cnt == WIDTH-1)
      pulseo <= '0;
    else 
      cnt <= cnt + 1'b1;
  end
end

end
endgenerate





endmodule