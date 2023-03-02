// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module varcic_downsampler_tb;

parameter         WIDTH_I       = 16;      // Input data width
parameter         WIDTH_O       = 17;      // Input data width
parameter         STAGES        = 3;       // Integrator-Comb stages
parameter         MAX_DECIMATION  = 16;    // Maximum Decimation factor
parameter         RATES           = 4;     // Output sample rates
parameter integer DEC_ARR[RATES]  = '{2, 4, 8, 16}; // Decimation factor array
parameter         WIDTH_S         = $clog2(RATES);
   
logic                               rst_i;      
// logic signal bus
logic   signed  [WIDTH_I - 1:0]     data_i;     
logic                               data_val_i; 
logic [WIDTH_S - 1:0]               dec_sel_i;  
// Output signal bus
logic  signed  [WIDTH_O - 1:0]      data_o;     
logic                               data_val_o;

logic clk_i = '0;
localparam HALFTICK = 5;
initial forever #HALFTICK clk_i <= #HALFTICK ~clk_i;

logic signed [WIDTH_I - 1:0] sine_o;
logic signed [WIDTH_I - 1:0] cos_o;

varcic_downsampler #(
  .WIDTH_I        (WIDTH_I),
  .WIDTH_O        (WIDTH_O),
  .STAGES         (STAGES),
  .MAX_DECIMATION (MAX_DECIMATION),
  .RATES          (RATES),
  .DEC_ARR        (DEC_ARR)
) varcic_downsampler_instance (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .data_i         (sine_o),
  .data_val_i     (data_val_i),
  .dec_sel_i      (dec_sel_i),
  .data_o         (data_o),
  .data_val_o     (data_val_o)
);

sine_tb #(
  .DWIDTH     (WIDTH_I),
  .PHASE_MAX  (4096)
) sine_tb_instance (
  .clk_i      (clk_i),
  .rst_i      (rst_i),
  .clk_ena_i  (data_val_i),
  .sine_o     (sine_o),
  .cos_o      (cos_o)
);

initial begin
  rst_i <= '0;
  #1 rst_i <= '1;
  #100 rst_i <= '1;
  @ (posedge clk_i);
  rst_i <= '0;
end

initial begin
  data_val_i <= '1;
  dec_sel_i <= 3;
end

endmodule // varcic_downsampler_tb
