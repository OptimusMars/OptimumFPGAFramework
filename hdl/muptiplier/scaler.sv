// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module scaler
#(
  parameter IWIDTH      = 16,  // Input data width
  parameter OWIDTH      = 16,  // Output data width
  parameter real SCALE  = 1.046566592,
  parameter FRAC        = 16,    // Fractional part
  parameter TYPE        = "TRUNC"  // "TRUNC", "LIMIT", "ROUND"
)
(
  input                         clk_i,
  input                         rst_i,
  
  input                         clk_en_i,
  
  input signed [IWIDTH - 1:0]   sig_i,
  
  output signed [OWIDTH - 1:0]  sig_o,
  output logic                  sig_fault
  
);

function integer rtoi (input integer x);
  rtoi = x;
endfunction

`define FLOOR(x) ((rtoi(x) > x) ? rtoi(x) - 1 : rtoi(x))

localparam MAX_VALUE = 2**(OWIDTH-1) - 1;
localparam MIN_VALUE = $signed(-MAX_VALUE);

localparam INT = `FLOOR(SCALE);
localparam SWIDTH = INT + FRAC + 1;   // Scaller width
localparam SCALE_REAL = SCALE*2**FRAC;
localparam SCALE_VAL = `FLOOR(SCALE_REAL);
localparam RWIDTH = SWIDTH + IWIDTH;  // Result width

logic signed [SWIDTH - 1: 0] scale_i;
typedef logic signed [SWIDTH - 1: 0] scale_t;
logic signed [RWIDTH - 1: 0] mult /* synthesis multstyle = "dsp" */;
logic signed [RWIDTH - 1: 0] mult_r;

logic signed [OWIDTH - 1:0]     sig;
logic signed [RWIDTH - FRAC:0]  sig_pre_lim;

assign mult = sig_i * scale_i;      // Multiply data on coefficient

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) mult_r <= '0;
  else if (clk_en_i) mult_r <= mult;
end

always_comb begin
  scale_i <= scale_t'(SCALE_VAL);
  sig_pre_lim <= mult_r >>> FRAC;
  if(TYPE == "LIMIT") begin
    if(sig_pre_lim > MAX_VALUE || sig_pre_lim < MIN_VALUE)
      sig_fault <= '1;
    else
      sig_fault <= '0;  
  end
  else 
    sig_fault <= '0;  
end

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) sig <= '0;
  else begin
    if(TYPE == "TRUNC")
      sig <= sig_pre_lim;
    else if (TYPE == "LIMIT") begin
      if(sig_pre_lim > MAX_VALUE)
        sig <= MAX_VALUE;
      else if(sig_pre_lim < MIN_VALUE)
        sig <= MIN_VALUE;
      else 
        sig <= sig_pre_lim;
    end
    else if (TYPE == "ROUND")
      $error("Function cannot round yet");
    else 
      $error("Invalid TYPE parameter. Should be TRUNC, LIMIT, ROUND");
  end
end

assign sig_o = sig;

endmodule // scaler
