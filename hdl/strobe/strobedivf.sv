// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module strobedivf
#(
  parameter         MAX_DIV   = 1000,     // Maximum integer divisor
  parameter         MAX_FRAC  = 10000,    // Maximum fracture divisor
  parameter         DIVISORS  = 4,        // Divisor array len
  parameter integer DIV_ARRAY[DIVISORS]   = '{ 2, 4, 8, 16},        // Integer divisor vector
  parameter integer FRAC_ARRAY[DIVISORS]  = '{ 833, 666, 444, 333}, // Fracture divisor vector
  // Localparams
  parameter         WIDTH_D = $clog2(DIVISORS)    // Width of selector
)
(
  input                 clk_i,      
  input                 rst_i,
  input                 clk_en_i,   // Input clock ena
  input                 strobe_i,   // Input strobe
  input [WIDTH_D-1:0]   div_sel_i,  // Divisor selector
  output                strobe_o    // Output strobe
);

integer k = 0;
initial begin
  if(MAX_FRAC % 10)
    $fatal("MAX_FRAC must be multiple of 10");  
  for (k = 0; k < DIVISORS; k++) begin
    if(DIV_ARRAY[k] < 1)
      $fatal("DIV_ARRAY must be greater than 0");
    if(DIV_ARRAY[k] > MAX_DIV)
      $fatal("DIV_ARRAY element is greater than MAX_DIV");
    if(FRAC_ARRAY[k] > MAX_FRAC)
      $fatal("FRAC_ARRAY element is greater than MAX_FRAC");
  end
end

localparam DIV_W    = $clog2(MAX_DIV);
localparam FRAC_W   = $clog2(MAX_FRAC);

logic [DIV_W:0]   div_cnt;        // Integer divisor counter
logic [FRAC_W:0]  frac_cnt;       // Fracture counter
logic             frac_exceed;

logic [FRAC_W-1:0] frac_inc;      // Fracture counter incrementor
logic [FRAC_W-1:0] frac_inc_a[DIVISORS];    // ------------ Array

logic [DIV_W-1:0]  div_max;             
logic [DIV_W-1:0]  div_max_a[DIVISORS];
logic              div_exceed;

typedef logic [FRAC_W-1:0]  frac_t;
typedef logic [DIV_W-1:0]   div_t;

generate 
  genvar i;
  for (i = 0; i < DIVISORS; i++) begin: divisor_processing
    assign frac_inc_a[i] = frac_t'(FRAC_ARRAY[i]);
    assign div_max_a[i] = div_t'(DIV_ARRAY[i] - 1);
  end
endgenerate

assign frac_inc = frac_inc_a[div_sel_i];
assign div_max = div_max_a[div_sel_i];
assign frac_exceed = frac_cnt >= MAX_FRAC;

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) frac_cnt <= '0;
  else if (strobe_i) frac_cnt <= '0;
  else if (div_exceed) begin 
    if (frac_exceed) frac_cnt <= frac_cnt + frac_inc - frac_t'(MAX_FRAC);
    else frac_cnt <= frac_cnt + frac_inc;
  end
end

always_comb begin
  if(frac_exceed) div_exceed <= div_cnt == (div_max + 1'b1);
  else div_exceed <= div_cnt == div_max;
end

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) div_cnt <= '0;
  else if (strobe_i) div_cnt <= '0;
  else if (clk_en_i && div_exceed) div_cnt <= '0;
  else if (clk_en_i) div_cnt <= div_cnt + 1'b1;

logic strobe;
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) strobe <= '0;
  else strobe <= strobe ? '0 : (clk_en_i && (div_exceed || strobe_i));

assign strobe_o = strobe;

endmodule // strobe_div_frac
