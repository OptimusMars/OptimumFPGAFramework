// Automatic 2-way handshake syncronizer
module dsync #(parameter DWIDTH = 8) (
  input                     rst ,
  //!
  input                     clki,
  input        [DWIDTH-1:0] din ,
  output logic              lost,
  //!
  input                     clko,
  output logic [DWIDTH-1:0] dout
);

logic [DWIDTH-1:0] hold;

logic change     ;
logic mask_change;
logic ack        ;
logic dval       ;

bus_edet #(.DWIDTH(DWIDTH)) i_bus_edet (.clk(clki), .din(din), .change(change));

always_ff @(posedge clki or posedge rst) begin
  if(rst) begin
    hold        <= '0;
    mask_change <= '0;
  end else if (change && !mask_change) begin
    hold        <= din;
    mask_change <= '1;
  end else if (ack) begin
    mask_change <= '0;
  end
end

esync i_esync (.rst(rst), .clki(clki), .clko(clko), .in(change), .out(dval));
esync i_esync (.rst(rst), .clki(clko), .clko(clki), .in(dval), .out(ack));

always_ff @(posedge clko) dout <= dval ? hold : dout;

assign lost = change && mask_change;

endmodule : dsync