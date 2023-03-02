package tb_helper;

task automatic clk_gen(ref clk_src, int period);
  clk_src = '0;
  #period;
  forever #period clk_src = ~clk_src;
endtask

task automatic pulse_gen(ref clk_, logic sig_);
  sig_ = '0;
  @ (posedge clk_);
  sig_ = '1;
  @ (posedge clk_);
  sig_ = '0;
endtask

task automatic wait_ticks(ref clk_src, int ticks);
  repeat(ticks) begin
    @ (posedge clk_src);
  end
endtask

task automatic reset_gen(ref reset_, clk_, int ticks);
  automatic int pause = 1;
  reset_ = '1;
  wait_ticks(clk_, ticks);
  reset_ = '0;
  wait_ticks(clk_, pause);
endtask

task automatic wait_not_rst(ref reset_, clk_);
  int ticks = 1;
  wait_ticks(clk_, ticks);
  wait(!reset_);
  wait_ticks(clk_, ticks);
endtask
  
endpackage : tb_helper