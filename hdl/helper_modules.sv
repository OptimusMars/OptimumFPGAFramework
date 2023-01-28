// Helper modules library for design simplification

// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

// Edge detector module
module edet (clk, in, sedge);
	parameter string EDGE = "POS"; // "POS" "NEG" , "BOTH" - Edge detector type  
	
  initial begin
    if(EDGE != "POS" && EDGE != "NEG" && EDGE != "BOTH")
      $error("Block %s: parameter EDGE is illegal", `__FILE__);
  end
  
	input clk;
	input in;
	output sedge;
	
	logic in_d;
	
	always_ff @ (posedge clk) in_d <= in;
	
	generate 
		if (EDGE == "POS") assign sedge = in & ~in_d;
		else if (EDGE == "NEG") assign sedge = ~in & in_d;
		else if (EDGE == "BOTH") assign sedge = in ^ in_d;
	endgenerate	
  
endmodule 

// Low-pass filter for signals
module lpf
#(
  parameter LPF_LEN = 4   // LPF delay length
)
(
  input         clk_i,
  input         rst_i,
  input         sig_i,
  output logic  sig_o
);

localparam LPF_MID        = LPF_LEN/2;                // Middle of hysteresis
localparam LPF_MID_DIV2   = LPF_MID/2;                // Hysteresis value
localparam LPF_TOP        = LPF_MID + LPF_MID_DIV2;   // Top of hysteresis
localparam LPF_BOT        = LPF_MID - LPF_MID_DIV2;   // Bottom of hysteresis

initial begin
  if ( LPF_LEN < 4 ) $error("LPF length must be greater than 4");
end

logic [$clog2(LPF_LEN) - 1:0] counter;    // Hysteresis counter

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    counter <= '0;
    sig_o <= '0;
  end
  else begin
    if (sig_i) begin
      if (counter != LPF_LEN - 1) 
        counter <= counter + 1'b1;	
    end
    else begin
      if (counter != 0) 
        counter <= counter - 1'b1;	
    end
    
    if (sig_o && counter <= LPF_BOT) sig_o <= '0;
    else if (!sig_o && counter >= LPF_TOP) sig_o <= '1;
    
  end
end

endmodule // lpf

// Syncronization chain for level signals
module regchain 
#(
  parameter SYNC_LEN = 3
)
(
  input   clk,     // syncronization clock
  input   sig_i,   // level signal to be syncronized
  output  sig_o    // syncronized signal
);
   
initial begin
  if (SYNC_LEN < 2) $error("SYNC_LEN must be greater than 1");
end

logic [SYNC_LEN - 1:0] registers;

always_ff @(posedge clk)
  registers <= { registers[SYNC_LEN - 2:0], sig_i };

assign sig_o = registers[SYNC_LEN - 1]; 

endmodule

// Active low reset filter 

module rstn_filt
#(
  parameter PULSE_HOLD = 3
) 
(
	input     clk,        // Syncronization clock
  input     enable,     // Enable signal
	input     rstn,       // Active low reset signal to be syncronized
	output    rstn_out    // Syncronized reset
);

logic [PULSE_HOLD-1:0] rstn_reg /* synthesis preserve */;
// initial rstn_reg = {PULSE_HOLD{1'b0}};

always_ff @(posedge clk or negedge rstn)
  if (!rstn) rstn_reg <= {PULSE_HOLD{1'b0}};
  else rstn_reg <= { enable, rstn_reg[PULSE_HOLD-1:1] };

assign rstn_out = rstn_reg[0];

endmodule

// Active high reset filter
module rst_filt
#(
  parameter PULSE_HOLD = 3
) 
(
	input   clk,        // Input clock
  input   rst,        // Reset to be syncronized
	output  rst_out     // Syncronized reset signal
);

logic [PULSE_HOLD-1:0] rst_reg /* synthesis preserve */;
// initial rst_reg = {PULSE_HOLD{1'b1}};

always_ff @(posedge clk or posedge rst)
  if (rst) rst_reg <= {PULSE_HOLD{1'b0}};
  else rst_reg <= {1'b1, rst_reg[PULSE_HOLD-1:1]};

assign rst_out = !rst_reg[0];

endmodule

// Two pipeline adder - very fast
module pipeline_add_msb 
#(
  parameter LS_WIDTH = 32,      // Low signal width
  parameter MS_WIDTH = 32,      // High signal width
  parameter WIDTH = LS_WIDTH + MS_WIDTH   // All width
)
(
  input                         clock,
  input                         reset,
  input         [WIDTH - 1:0]   dataa,
  input         [WIDTH - 1:0]   datab,
  output logic  [WIDTH - 1:0]   datao,
  output                        msb
);

initial begin
  if(WIDTH != LS_WIDTH + MS_WIDTH)
    $fatal("WIDTH != (LS_WIDTH + MS_WIDTH) in %s %s", `__FILE__, `__LINE__);
end

// Build the less significant adder with an extra bit on the top to get
// the carry chain onto the normal routing.  
logic [LS_WIDTH-1+1:0] ls_adder;
wire cross_carry = ls_adder[LS_WIDTH];
always @(posedge clock or posedge reset) begin
  if (reset) ls_adder <= 1'b0;
  else ls_adder <= {1'b0, dataa[LS_WIDTH-1:0]} + {1'b0,datab[LS_WIDTH-1:0]};
end

// the more significant data needs to wait dataa tick for the carry
// signal to be ready
logic [MS_WIDTH-1:0] ms_data_a,ms_data_b;
always @(posedge clock or posedge reset) begin
  if (reset) begin
    ms_data_a <= 0;
    ms_data_b <= 0;
  end
  else begin
    ms_data_a <= dataa[ WIDTH-1: WIDTH-MS_WIDTH];
    ms_data_b <= datab[ WIDTH-1: WIDTH-MS_WIDTH];
  end
end

// Build the more significant adder with an extra low bit to incorporate
// the carry from the split lower chain.
wire [MS_WIDTH-1+1:0] ms_adder;
assign ms_adder = {ms_data_a, cross_carry} +  {ms_data_b, cross_carry};

assign msb = ms_adder[MS_WIDTH];

// collect the sum back together and register, drop the two internal bits
always @(posedge clock or posedge reset) begin
  if (reset) datao <= 0;
  else datao <= {ms_adder[MS_WIDTH:1], ls_adder[LS_WIDTH-1:0]};
end

endmodule

// Two pipeline substractor - very fast
module pipeline_sub_msb  #(
  parameter LS_WIDTH = 32,
  parameter MS_WIDTH = 32,
  parameter WIDTH = LS_WIDTH + MS_WIDTH
)
(
  input                         clock,
  input                         reset,
  input         [WIDTH - 1:0]   dataa,
  input         [WIDTH - 1:0]   datab,
  output logic  [WIDTH - 1:0]   datao,
  output                        msb
);

// Build the less significant adder with an extra bit on the top to get
// the carry chain onto the normal routing.  
logic [LS_WIDTH-1+1:0] ls_sub;
wire cross_carry = ls_sub[LS_WIDTH];
always @(posedge clock or posedge reset) begin
  if (reset) ls_sub <= 1'b0;
  else ls_sub <= {1'b0, dataa[LS_WIDTH-1:0]} - {1'b0,datab[LS_WIDTH-1:0]};
end

// the more significant data needs to wait dataa tick for the carry
// signal to be ready
logic [MS_WIDTH-1:0] ms_data_a, ms_data_b;
always @(posedge clock or posedge reset) begin
  if (reset) begin
    ms_data_a <= '0;
    ms_data_b <= '0;
  end
  else begin
    ms_data_a <= dataa[ WIDTH-1: WIDTH - MS_WIDTH];
    ms_data_b <= datab[ WIDTH-1: WIDTH - MS_WIDTH];
  end
end

// Build the more significant adder with an extra low bit to incorporate
// the carry from the split lower chain.
wire [MS_WIDTH-1+1:0] ms_sub;
assign ms_sub = { ms_data_a, cross_carry } - { ms_data_b, cross_carry };

assign msb = ms_sub[MS_WIDTH];

// collect the sum back together and register, drop the two internal bits
always @(posedge clock or posedge reset) begin
  if (reset) datao <= 0;
  else datao <= { ms_sub[MS_WIDTH:1], ls_sub[LS_WIDTH-1:0] };
end

endmodule

// Parallel Adder with pipelining
module adder_parallel 
#(
  parameter WIDTH_I = 64,
  parameter INPUTS = 2,
  parameter PEPRESENTATION = "SIGNED",  // "UNSIGNED"
  parameter PIPELINE = 2,
  parameter WIDTH_O = WIDTH_I + $clog2(INPUTS)
)
(
	input                             clock, 
  input                             reset, 
  input                             clken, 
  input [WIDTH_I * INPUTS - 1:0]    data,
	output [WIDTH_O - 1:0]            result
);

generate 
if( PIPELINE == 0 ) begin
  parallel_add	
  parallel_add_component (
    .data       (data),
    .result     (result)
  );
	defparam
		parallel_add_component.msw_subtract = "NO",
		parallel_add_component.pipeline = PIPELINE,
		parallel_add_component.representation = PEPRESENTATION,
		parallel_add_component.result_alignment = "LSB",
		parallel_add_component.shift = 0,
		parallel_add_component.size = INPUTS,
		parallel_add_component.width = WIDTH_I,
		parallel_add_component.widthr = WIDTH_O;
    
end
else begin
  parallel_add	
  parallel_add_component (
    .data       (data),
    .result     (result),
    .aclr       (reset),
    .clken      (clken),
    .clock      (clock)
    );
	defparam
		parallel_add_component.msw_subtract = "NO",
		parallel_add_component.pipeline = PIPELINE,
		parallel_add_component.representation = PEPRESENTATION,
		parallel_add_component.result_alignment = "LSB",
		parallel_add_component.shift = 0,
		parallel_add_component.size = INPUTS,
		parallel_add_component.width = WIDTH_I,
		parallel_add_component.widthr = WIDTH_O;
end
endgenerate

endmodule

// Syncronization chain for edge signals
module sync_edge 
(
  input   clk_in,     // syncronization clock input
  input   clk_out,    // syncronization clock
  input   rst,      // arst
  input   sig_in,     // edge signal to be syncronized
  output  sig_out     // edge syncronized signal
);

parameter SYNC_LEN = 3;   

initial
if (SYNC_LEN < 2)
  $error("SYNC_LEN must be greater than 1");

bit toggle = '0;
  
always_ff @(posedge clk_in, posedge rst)
  if(rst) toggle <= '0;
  else if(sig_in) toggle <= ~toggle;
    
bit [SYNC_LEN - 1:0] sync_reg;
bit sync_reg_d;
// Sync chain
always_ff @(posedge clk_out, posedge rst)
  if(rst) sync_reg <= '0;
  else sync_reg <= { sync_reg[SYNC_LEN - 2:0], toggle };

always_ff @(posedge clk_out, posedge rst)
  if(rst) sync_reg_d <= '0;
  else sync_reg_d <= sync_reg[SYNC_LEN - 1];

// Posedge detection
assign sig_out = sync_reg[SYNC_LEN - 1] ^ sync_reg_d;

endmodule

// Syncronization chain for edge signals
module sync_pulse
(
  input   clk_in,     // syncronization clock input
  input   clk_out,    // syncronization clock
  input   rst,      // arst
  input   sig_in,     // edge signal to be syncronized
  output  sig_out     // edge syncronized signal
);

parameter SYNC_LEN = 3;   

initial if (SYNC_LEN < 2)
  $error("SYNC_LEN must be greater than 1");

bit latch = '0;
bit reset_latch;

assign reset_latch = sync_reg[SYNC_LEN - 1] || rst;

always_ff @(posedge clk_in, posedge reset_latch)
  if(reset_latch) latch <= '0;
  else if(sig_in) latch <= '1;
    
bit [SYNC_LEN - 1:0] sync_reg;
bit sync_reg_d;
// Sync chain
always_ff @(posedge clk_out, posedge rst)
  if(rst) sync_reg <= '0;
  else sync_reg <= { sync_reg[SYNC_LEN - 2:0], latch };

always_ff @(posedge clk_out, posedge rst)
  if(rst) sync_reg_d <= '0;
  else sync_reg_d <= sync_reg[SYNC_LEN - 1];

// Posedge detection
assign sig_out = ~sync_reg_d && sync_reg[SYNC_LEN - 1];

endmodule

// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module clk_det
#(
	
	parameter string FILTER_OUTPUT = "YES",		// enable lpf 
	parameter CNT_WIDTH = 5	
)
(
	input ref_clock,        // Reference clock. F_ref must be less than F_test
	input test_clock,       // Test Clock
	output clock_exist			// 1 - exist; 0 - not exist
);

localparam SYNC_STAGE = 2;	 // Number of sync stages
localparam LATENCY = SYNC_STAGE + 1;		// 2 minimum

initial begin
  if(CNT_WIDTH < 2)
    $error("Block %s: CNT_WIDTH must be >= 2", `__FILE__);
end
	

logic [LATENCY - 1:0] latency = '0;
logic trig0;
logic trig_rst;
logic [SYNC_STAGE - 1:0] trig1;

assign trig_rst = trig1[SYNC_STAGE - 1];
always_ff @(posedge ref_clock or posedge trig_rst)
  if(trig_rst) latency <= '0;
  else latency <= { latency[LATENCY - 2:0], 1'b1 };

always_ff @(posedge test_clock or posedge trig_rst)
  if(trig_rst) trig0 <= '0;
  else trig0 <= '1;

always_ff @(posedge ref_clock)
  trig1 <= { trig1[SYNC_STAGE - 2:0], trig0 };

generate
  if (FILTER_OUTPUT == "YES") begin: filt
    logic [CNT_WIDTH - 1:0] cnt_lpf;
    logic lpf_out;
    assign lpf_out = (cnt_lpf == (2**CNT_WIDTH - 1));
    assign clock_exist = ~lpf_out;
    always_ff @(posedge ref_clock or posedge trig_rst)
      if(trig_rst)
        cnt_lpf <= '0;
      else if(cnt_lpf != (2**CNT_WIDTH - 1))
        cnt_lpf <= cnt_lpf + 1'b1;
  end
  else 
    assign clock_exist = ~latency[LATENCY - 1];
endgenerate
	
endmodule // clock_detector 

// Clock divisor module
module clk_div
#(
  parameter string GEN_BLOCK = "YES",
  parameter DIV_MAX = 8     // Maximum divisor
)
(
  input                         clk,
  input                         rst, 
  input [$clog2(DIV_MAX) - 1:0] div,
  output                        clk_div
);

generate
if(GEN_BLOCK == "YES") begin

  logic clk_div_r;
  logic [$clog2(DIV_MAX) - 1:0] cnt_div;
  wire equal_cnt = (cnt_div == div - 1) ? '1 : '0;
  wire equal_zero = (div == 0) ? '1 : '0;

  always_ff @ (posedge clk, posedge rst)
    if(rst) cnt_div <= '0;
    else if(equal_cnt) cnt_div <= '0;
    else cnt_div <= cnt_div + 1'b1;

  always_ff @ (posedge clk, posedge rst)
    if(rst) clk_div_r <= '0;
    else if(equal_cnt) clk_div_r <= ~clk_div_r;

  assign clk_div = equal_zero ? clk : clk_div_r;

end
else
  assign clk_div = '0;
endgenerate

endmodule

// Strobe divisor module
module strobe_div
#(
  parameter DIV_WIDTH = 10    // Divisor width
)
(
  input                   clk_i,
  input                   rst_i,
  input                   strobe_i,     
  input [DIV_WIDTH - 1:0] divisor_i,    // Strobe integer divisor, 
  output logic            strobe_o,
  output logic            strobe_div_o
);

logic                   strobe_en;
logic                   strobe_i_d = '0;
logic [DIV_WIDTH - 1:0] cnt_div;

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) strobe_en <= '0;
  else if (cnt_div == divisor_i && strobe_i) strobe_en <= '1;
  else if (strobe_i) strobe_en <= '0;

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) cnt_div <= '0;
  else if (cnt_div == divisor_i && strobe_i) cnt_div <= '0;
  else if (strobe_i) cnt_div <= cnt_div + 1'b1;

always_ff @ (posedge clk_i)
  strobe_i_d <= strobe_i;

always_comb begin
  strobe_o <= strobe_i_d;
  strobe_div_o <= strobe_i_d && strobe_en;
end

endmodule // strobe_div

// Delay chain on registers
module delay
#(
  parameter WIDTH = 16,   // Width of signals
  parameter DELAY = 0     // Delay value
)
(
  input                         clk_i,
  input                         rst_i,
  input                         clk_en_i, 
  input   [WIDTH - 1:0]         data_i, 
  output  [WIDTH - 1:0]         delay_o, 
  output  [WIDTH*(DELAY+1)-1:0] delay_taps
);

initial 
if ( WIDTH == 0 )
  $error("Width cannot be zero");

genvar i;
generate 
  if(DELAY == 0) begin
    assign delay_o = data_i;
    assign delay_taps = data_i;
  end
  else begin
    logic [WIDTH - 1:0] chain [DELAY - 1:0];    // Delay chain
    
    
    assign delay_taps[0*WIDTH +: WIDTH] = data_i; // First tap its data
    assign delay_o = chain[DELAY - 1];    // Delayed data
    // Other taps delayed
    for (i = 1; i < DELAY + 1; i++) begin : taps_process
      assign delay_taps[i*WIDTH +: WIDTH] = chain[i-1];
    end
    // Delay chain
    always_ff @ (posedge clk_i or posedge rst_i) begin
      for (int j = 0; j < DELAY; j++) begin
        if (rst_i) chain[j] <= '0;
        else if(clk_en_i) begin
          if(j == 0) chain[j] <= data_i;
          else chain[j] <= chain[j - 1];
        end
      end
    end
  end
endgenerate

endmodule // delay


