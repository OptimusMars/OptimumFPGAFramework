module clkdet #(
  parameter FILTER_OUTPUT = "YES", // enable lpf
  parameter CNT_WIDTH     = 5
) (
  input  clkref, // Reference clock. F_ref must be less than F_test
  input  clktst, // Test Clock
  output exist   // 1 - exist; 0 - not exist
);

localparam SYNC_STAGE = 2;   // Number of sync stages
localparam LATENCY = SYNC_STAGE + 1;    // 2 minimum

initial if(CNT_WIDTH < 2)
  $error("Block %s: CNT_WIDTH must be >= 2", `__FILE__);
  
logic [LATENCY - 1:0] latency;
logic trig0;
logic trig_rst;
logic [SYNC_STAGE - 1:0] trig1;

assign trig_rst = trig1[SYNC_STAGE - 1];
always_ff @(posedge clkref or posedge trig_rst)
  if(trig_rst) latency <= '0;
  else latency <= { latency[LATENCY - 2:0], 1'b1 };

always_ff @(posedge clktst or posedge trig_rst)
  if(trig_rst) trig0 <= '0;
  else trig0 <= '1;

always_ff @(posedge clkref)
  trig1 <= { trig1[SYNC_STAGE - 2:0], trig0 };

generate
  if (FILTER_OUTPUT == "YES") begin: filt
    logic [CNT_WIDTH - 1:0] cnt_lpf;
    logic lpf_out;
    assign lpf_out = (cnt_lpf == (2**CNT_WIDTH - 1));
    assign exist = ~lpf_out;
    always_ff @(posedge clkref or posedge trig_rst)
      if(trig_rst)
        cnt_lpf <= '0;
      else if(cnt_lpf != (2**CNT_WIDTH - 1))
        cnt_lpf <= cnt_lpf + 1'b1;
  end
  else 
    assign exist = ~latency[LATENCY - 1];
endgenerate
  
endmodule // clock_detector 