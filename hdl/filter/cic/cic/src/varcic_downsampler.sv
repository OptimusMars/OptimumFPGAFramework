
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module varcic_downsampler
#(
  parameter         WIDTH_I         = 16,       // Input data width
  parameter         WIDTH_O         = WIDTH_I,  // Output data width
  parameter         STAGES          = 3,        // Integrator-Comb stages
  parameter         MAX_DECIMATION  = 16,       // Maximum Decimation factor
  parameter         RATES           = 4,        // Output sample rates
  parameter integer DEC_ARR[RATES]  = '{2, 4, 8, 16}, // Decimation factor array
  // Localparam
  parameter         WIDTH_S         = $clog2(RATES)
)
(
  input                                 clk_i,      // Clock
  input                                 rst_i,      // Async Reset
  // Input signal bus
  input   signed  [WIDTH_I - 1:0]       data_i,     // Input data for decimation
  input                                 data_val_i, // Input data valid signal
  input [WIDTH_S - 1:0]                 dec_sel_i,  // Decimation selector
  // Output signal bus
  output logic signed  [WIDTH_O - 1:0]  data_o,     // Output data with cic gain
  output  logic                         data_val_o  // Output data valid
);

integer ii;
localparam WIDTH_GAIN = WIDTH_I + STAGES * $clog2(MAX_DECIMATION);    // Maximum output width
initial begin
  if(STAGES < 2) $fatal("STAGES parameter must be greater than 2");
  if((MAX_DECIMATION < 2)) $fatal("DECIMATION must be greater than 2");
  ii = 0;
  for (ii = 0; ii < RATES; ii++) begin
    if(DEC_ARR[ii] > MAX_DECIMATION)
      $fatal("MAX_DECIMATION parameter set wrong");
  end
end

logic signed [WIDTH_GAIN - 1:0] integrator_stages[STAGES];     // Integrator stages
logic signed [WIDTH_GAIN - 1:0] comb_stages[STAGES];           // Comb stages

// Integration chain
generate 
  genvar j;
  
  cic_integrator #(WIDTH_GAIN) 
  cic_integrator_inst(
    .clk_i          (clk_i),
    .clk_en_i       (data_val_i),
    .reset_i        (rst_i),
    .data_i         ({ { (WIDTH_GAIN - WIDTH_I) {data_i[WIDTH_I - 1]}} , data_i}),
    .data_o         (integrator_stages[0])
  );
  
  for(j = 1; j < STAGES; j++) begin: integration_stages_for
    cic_integrator #(WIDTH_GAIN) 
    cic_integrator_inst(
      .clk_i          (clk_i),
      .clk_en_i       (data_val_i),
      .reset_i        (rst_i),
      .data_i         (integrator_stages[j-1]),
      .data_o         (integrator_stages[j])
    );
  end
endgenerate

logic [$clog2(MAX_DECIMATION) - 1:0] clk_div;  // Division input clock rate to decimation factor
logic div_max;
logic div_zero;
logic data_val_o_int;

integer deci_array[RATES - 1:0];
integer deci;
logic signed [WIDTH_O-1:0] sel_array[RATES - 1:0];

generate 
  genvar k;
  for (k = 0; k < RATES; k++) begin : width_compute_for
    assign deci_array[k] = DEC_ARR[k] - 1;
    varcic_sel #(WIDTH_GAIN, WIDTH_I, WIDTH_O, STAGES, DEC_ARR[k]) 
    varcic_sel (comb_stages[STAGES - 1], sel_array[k]);
  end
endgenerate

always_comb begin
  deci <= deci_array[dec_sel_i];      // Decimation mux out
  div_max <= clk_div == deci;
  div_zero <= clk_div == '0;
end

always_ff @ (posedge clk_i or posedge rst_i) begin
  if ( rst_i ) clk_div <= '0;
  else if(div_max) clk_div <= '0;
  else clk_div <= clk_div + 1'b1;
end

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) data_val_o_int <= '0;
  else if(data_val_i && div_zero) data_val_o_int <= '1;
  else data_val_o_int <= '0;

//-------------------------------------------------

// Comb section
generate 
  genvar i;
  
  cic_comb #(WIDTH_GAIN) 
  cic_comb_inst_pre (
    .clk_i        (clk_i),
    .clk_en_i     (data_val_o_int),
    .reset_i      (rst_i),
    .data_i       (integrator_stages[STAGES - 1]),
    .data_o       (comb_stages[0])
  );
  
  for (i = 1; i < STAGES; i++) begin: comb_stages_for
    cic_comb #(WIDTH_GAIN) 
    cic_comb_inst(
      .clk_i        (clk_i),
      .clk_en_i     (data_val_o_int),
      .reset_i      (rst_i),
      .data_i       (comb_stages[i - 1]),
      .data_o       (comb_stages[i])
    );
  end  
endgenerate

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    data_val_o <= '0; 
    data_o    <= '0;
  end
  else begin
    data_val_o <= data_val_o_int;
    data_o     <= sel_array[dec_sel_i];
  end
end

endmodule // varcic_downsampler
