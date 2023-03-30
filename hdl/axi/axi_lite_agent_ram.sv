module axi_lite_agent_ram #(
  parameter SIZE = 2048
) (
  input clk,    
  input rst,  

  axi4lite_intf.slave      axi
  
);

localparam AWIDTH = $clog2(SIZE);

logic [AWIDTH-1:0] addra, addrb;

dprambe #(.DWIDTH(32), .AWIDTH(AWIDTH), .REGOUT("Y")) i_dprambe (
  .clka (clk       ),
  .wea  (axi.wvalid),
  .addra(addra     ),
  .dataa(axi.wdata ),
  .bea  (axi.wstrb ),
  .qa   (          ),
  
  .clkb (clk       ),
  .web  ('0        ),
  .addrb(addrb     ),
  .datab('0        ),
  .beb  ('1        ),
  .qb   (axi.rdata )
);

delayreg #(.WIDTH(1), .DELAY(2)) i_delayreg (
  .clk  (clk        ),
  .rst  (rst        ),
  .ena  ('1         ),
  .data (axi.arready),
  .delay(axi.rvalid ),
  .taps (           )
);

always_comb begin
  axi.rresp   = '0;
  axi.awready = '1;
  axi.wready  = '1;
  axi.bresp   = '0;
  axi.arready = '1;
end

always_ff @(posedge clk or posedge rst) begin
  if(rst) begin
    addra <= '0;
    addrb <= '0;
  end else begin
    addra      <= axi.awvalid ? axi.awaddr[AWIDTH-1:0] : addra;
    addrb      <= axi.arvalid ? axi.araddr[AWIDTH-1:0] : addrb;
    axi.bvalid <= axi.wready && axi.wvalid && axi.wready;
  end
end

endmodule