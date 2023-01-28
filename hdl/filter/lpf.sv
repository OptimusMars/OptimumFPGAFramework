// Low-pass filter for signals
module lpf
#(
  parameter LEN = 4   // LPF delay length
)
(
  input         clk,
  input         rst,
  input         in,
  output logic  out
);

localparam LPF_MID        = LEN/2;                // Middle of hysteresis
localparam LPF_MID_DIV2   = LPF_MID/2;                // Hysteresis value
localparam LPF_TOP        = LPF_MID + LPF_MID_DIV2;   // Top of hysteresis
localparam LPF_BOT        = LPF_MID - LPF_MID_DIV2;   // Bottom of hysteresis

initial begin
  if ( LEN < 4 ) $error("LPF length must be greater than 4");
end

logic [$clog2(LEN) - 1:0] cnt;    // Hysteresis cnt

always_ff @ (posedge clk or posedge rst) begin
  if (rst) begin
    cnt <= '0;
    out <= '0;
  end
  else begin
    if (in) begin
      if (cnt != LEN - 1) cnt <= cnt + 1'b1;  
    end
    else begin
      if (cnt != 0) cnt <= cnt - 1'b1;  
    end
    
    if (out && cnt <= LPF_BOT) out <= '0;
    else if (!out && cnt >= LPF_TOP) out <= '1;
    
  end
end

endmodule // lpf