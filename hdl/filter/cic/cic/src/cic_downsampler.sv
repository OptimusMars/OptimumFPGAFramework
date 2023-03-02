// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module cic_downsampler
#(
  parameter WIDTH_I       = 22,      // Input data width
  parameter WIDTH_O       = WIDTH_I, // Output data width
  parameter DECIMATION    = 2,       // Decimation Factor
  parameter STAGES        = 3,       // Integrator-Comb stages
  // Don't change this parameters
  parameter WIDTH_GAIN = WIDTH_I + STAGES * $clog2(DECIMATION)    // Output width. Do not modify
)
(
  input                               clk_i,          // Clock
  input                               rst_i,          // Async Reset
  // Input signal bus
  input   signed  [WIDTH_I - 1:0]     data_i,         // Input data for decimation
  input                               data_val_i,     // Input data valid signal
  
  // Output signal bus
  output  signed  [WIDTH_O - 1:0]     data_o,         // Output data with cic gain
  output  logic                       data_val_o      // Output data valid
);

initial begin
  if(STAGES < 2) $fatal("STAGES parameter must be greater than 2");
  if((DECIMATION < 2)) $fatal("DECIMATION must be greater than 2");
  if(WIDTH_O > WIDTH_GAIN) $fatal("WIDTH_O exceed WIDTH_GAIN");
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

logic [$clog2(DECIMATION) - 1:0] clk_div;  // Division input clock rate to decimation factor
logic div_max;
logic div_zero;
logic data_val_o_int;

always_comb begin
  div_max <= clk_div == DECIMATION - 1;
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

assign data_val_o   = data_val_o_int;
assign data_o = comb_stages[STAGES - 1][WIDTH_GAIN - 1:WIDTH_GAIN - WIDTH_O];

endmodule // cic_downsampler
