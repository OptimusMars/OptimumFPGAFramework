module dffeas(
  input clk,
  input clrn,
  input prn,
  input asload,
  input asdata,
  input sclr,
  input sload, 
  input ena, 
  input d,
  output logic q
);

logic q_async;
wire async_load = !clrn || !prn || asload;  

always_comb begin
  if      (!clrn)   q_async <= '0;
  else if (!prn)    q_async <= '1;
  else if (asload)  q_async <= asdata;
  else              q_async <= q_async; 
end

always_ff @(posedge clk, posedge async_load) begin
  if      (async_load)  q <= q_async;
  else if (ena)         q <= d;
  else                  q <= q;
end
  
endmodule
