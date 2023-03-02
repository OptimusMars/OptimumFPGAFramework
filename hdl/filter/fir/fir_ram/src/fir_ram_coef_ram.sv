//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR Simple
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_ram_coef_ram..sv
//-- created     : 14 марта 2020 г. : 10:45:42	
//-- author      : Martynov Ivan
//-- company     : Expert Electronix, Taganrog, Russia
//-- target      : [x] simulation  [x] synthesis
//-- technology  : [x] any
//-- tools & o/s : quartus 13.1 & windows 7
//-- dependency  :
//-------------------------------------------------------------------------------
//-- description : Memory for fir coeficients
//-- 
//--
//-------------------------------------------------------------------------------
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fir_ram_coef_ram
#(
  parameter COEF_FILE       = "fir_coef.mif",   // FIR coefficient filename
  parameter COEF_WIDTH      = 16,               // Coefficient
  parameter COEF_AWIDTH     = 9,                // Coefficients bus width
  parameter PORTS           = 4,                // Summultaneous port read
  parameter USE_COEF_WRITE  = 0
)
(
  input                             clk_i,
  input                             rst_i,
  
  input                             coef_we_i,
  input [COEF_AWIDTH-1:0]           coef_addr_i,
  input [COEF_WIDTH-1:0]            coef_data_i,
  
  input   [COEF_AWIDTH*PORTS-1:0]   coef_read_addr_i,
  output  [COEF_WIDTH*PORTS-1:0]    coef_read_data_o
  
);
localparam COEF_NUM = 2**COEF_AWIDTH;
localparam RAM_COUNT = (PORTS % 2 ) ? PORTS/2 + 1 : PORTS/2;    // Dual port ram count

genvar j;
generate 
if(PORTS == 1) begin
  logic [COEF_AWIDTH-1:0]    coef_address;
  always_comb begin
    if(USE_COEF_WRITE == 1)
      coef_address <= coef_we_i ? coef_addr_i : coef_read_addr_i;
    else 
      coef_address <= coef_read_addr_i;
  end
  ram_1port #(
    .DWIDTH       (COEF_WIDTH),
    .WORDS        (COEF_NUM),
    .INIT_FILE    (COEF_FILE)
  ) ram_1port_instance (
    .address  (coef_address[COEF_AWIDTH -1:0]),
    .clock    (clk_i),
    .data     (coef_data_i),
    .wren     (coef_we_i),
    .q        (coef_read_data_o)
  );
end
else begin
  logic [COEF_WIDTH*PORTS*2-1:0]     coef_q;
  logic [COEF_AWIDTH*PORTS*2-1:0]    coef_address;
  
  always_comb begin
    for (int i = 0; i < RAM_COUNT; i++) begin
      if(USE_COEF_WRITE == 1) begin
        coef_address[i*2*COEF_AWIDTH +: COEF_AWIDTH] <= 
          coef_we_i ? coef_addr_i[i*2*COEF_AWIDTH +: COEF_AWIDTH] : 
                      coef_read_addr_i[i*2*COEF_AWIDTH +: COEF_AWIDTH];
        if(i*2+1 < PORTS) begin
          coef_address[(i*2+1)*COEF_AWIDTH +: COEF_AWIDTH] <= 
            coef_we_i ? coef_addr_i[(i*2+1)*COEF_AWIDTH +: COEF_AWIDTH] : 
                        coef_read_addr_i[(i*2+1)*COEF_AWIDTH +: COEF_AWIDTH];
        end
        else
          coef_address[(i*2+1)*COEF_AWIDTH +: COEF_AWIDTH] <= '0;
      end
      else begin 
        coef_address[i*2*COEF_AWIDTH +: COEF_AWIDTH] <=  
                      coef_read_addr_i[i*2*COEF_AWIDTH +: COEF_AWIDTH];
        if(i*2+1 < PORTS) begin
          coef_address[(i*2+1)*COEF_AWIDTH +: COEF_AWIDTH] <=  
            coef_read_addr_i[(i*2+1)*COEF_AWIDTH +: COEF_AWIDTH];
        end
        else
          coef_address[(i*2+1)*COEF_AWIDTH +: COEF_AWIDTH] <= '0;           
      end
    end    
  end
  
  for (j = 0; j < RAM_COUNT; j++) begin: rom_processing
    // Processing address of ram    
    if(USE_COEF_WRITE == 1) begin
      ram_2port #(
        .DWIDTH     (COEF_WIDTH),
        .WORDS      (COEF_NUM),
        .INIT_FILE  (COEF_FILE)
      ) ram_2port_instance (
        .address_a    (coef_address[j*2*COEF_AWIDTH +: COEF_AWIDTH]),
        .address_b    (coef_address[(j*2+1)*COEF_AWIDTH +: COEF_AWIDTH]),
        .clock        (clk_i),
        .data_a       (coef_data_i),
        .data_b       (coef_data_i),
        .wren_a       (coef_we_i),
        .wren_b       (coef_we_i),
        .q_a          (coef_q[j*2*COEF_WIDTH +: COEF_WIDTH]),
        .q_b          (coef_q[(j*2+1)*COEF_WIDTH +: COEF_WIDTH])
      );
    end
    else begin
      rom_2port #(
        .DWIDTH     (COEF_WIDTH),
        .WORDS      (COEF_NUM),
        .INIT_FILE  (COEF_FILE)
      ) rom_2port_instance (
        .address_a  (coef_address[j*2*COEF_AWIDTH +: COEF_AWIDTH]),
        .address_b  (coef_address[(j*2+1)*COEF_AWIDTH +: COEF_AWIDTH]),
        .clock      (clk_i),
        .q_a        (coef_q[j*2*COEF_WIDTH +: COEF_WIDTH]),
        .q_b        (coef_q[(j*2+1)*COEF_WIDTH +: COEF_WIDTH])
      );
    end
  end
  assign coef_read_data_o = coef_q[COEF_WIDTH*PORTS-1:0];
end
endgenerate

endmodule // fir_ram_coef_ram
