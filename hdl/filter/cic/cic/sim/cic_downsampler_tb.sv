// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module cic_downsampler_tb;

parameter WIDTH_I       = 16;      // Input data width
parameter WIDTH_O       = 17;      // Output data width
parameter DECIMATION    = 64;       // Decimation Factor
parameter STAGES        = 4;       // Integrator-Comb stages

localparam HALFTICK = 5;

logic                               rst_i;          // Async Reset
// logic signal bus
logic   signed  [WIDTH_I - 1:0]     data_i;         // logic data for decimation
logic                               data_val_i;     // logic data valid signal
  
    // logic signal bus
logic  signed  [WIDTH_O - 1:0]     data_o;         // logic data with cic gain
logic                              data_val_o;     // logic data valid

logic clk_i = '0;
initial forever #HALFTICK clk_i <= #HALFTICK ~clk_i;

logic signed [WIDTH_I - 1:0] sine_o;
logic signed [WIDTH_I - 1:0] cos_o;

cic_downsampler #(
  .WIDTH_I      (WIDTH_I),
  .WIDTH_O      (WIDTH_O),
  .DECIMATION   (DECIMATION),
  .STAGES       (STAGES)
) cic_downsampler_instance (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .data_i         (sine_o),
  .data_val_i     (data_val_i),
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
end



endmodule // cic_downsampler_tb
