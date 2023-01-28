module systim
#(
  parameter CLOCK_MHZ = 200  
)
(
  input clk,rst,

  output logic [9:0] usec,
  output logic [9:0] msec,
  output logic [5:0] sec,
  output logic [5:0] min,
  output logic [4:0] hour,
  output logic [9:0] day,
    
  output logic usec_p,
  output logic msec_p,
  output logic sec_p
);

logic [7:0] tick_cntr;
logic tick_cntr_max;

// review tick counter design if leaving this range
// initial assert (CLOCK_MHZ > 64 && CLOCK_MHZ < 250);

always @(posedge clk) begin
  if (rst) begin
    tick_cntr <= 0;
    tick_cntr_max <= 0;
  end
  else begin
    if (tick_cntr_max) tick_cntr <= 1'b0;
    else tick_cntr <= tick_cntr + 1'b1;
    tick_cntr_max <= (tick_cntr == (CLOCK_MHZ - 2'd2));
  end
end

/////////////////////////////////
// Count off 1000 us to form 1 ms
/////////////////////////////////
logic usec_max;

always @(posedge clk) begin
  if (rst) begin
    usec <= 0;
    usec_max <= 0;
  end
  else if (tick_cntr_max) begin
    if (usec_max) usec <= 1'b0;
    else usec <= usec + 1'b1;
    usec_max <= (usec == 10'd998);
  end
end

/////////////////////////////////
// Count off 1000 ms to form 1 s
/////////////////////////////////
logic msec_max;

always @(posedge clk) begin
  if (rst) begin
    msec <= 0;
    msec_max <= 0;
  end
  else if (usec_max & tick_cntr_max) begin
    if (msec_max) msec <= 1'b0;
    else msec <= msec + 1'b1;
    msec_max <= (msec == 10'd998);
  end
end

/////////////////////////////////
// Count off 60s to form 1 m
/////////////////////////////////
logic sec_max;

always @(posedge clk) begin
  if (rst) begin
    sec <= 0;
    sec_max <= 0;
  end
  else if (msec_max & usec_max & tick_cntr_max) begin
    if (sec_max) sec <= 1'b0;
    else sec <= sec + 1'b1;
    sec_max <= (sec == 6'd58);
  end
end

/////////////////////////////////
// Count off 60m to form 1hr
/////////////////////////////////
logic min_max;

always @(posedge clk) begin
  if (rst) begin
    min <= 0;
    min_max <= 0;
  end
  else if (sec_max & msec_max & 
      usec_max & tick_cntr_max) begin
    if (min_max) min <= 1'b0;
    else min <= min + 1'b1;
    min_max <= (min == 6'd58);
  end
end

/////////////////////////////////
// Count off 24h to form 1day
/////////////////////////////////
logic hour_max;

always @(posedge clk) begin
  if (rst) begin
    hour <= 0;
    hour_max <= 0;
  end
  else if (min_max & sec_max & msec_max &
       usec_max & tick_cntr_max) begin
    if (hour_max) hour <= 1'b0;
    else hour <= hour + 1'b1;
    hour_max <= (hour == 5'd22);
  end
end

/////////////////////////////////
// Count off 1024 days then wrap
/////////////////////////////////
always @(posedge clk) begin
  if (rst) begin
    day <= 0;
  end
  else if (hour_max & min_max & sec_max & msec_max &
       usec_max & tick_cntr_max) begin
    day <= day + 1'b1;
  end
end

/////////////////////////////////////
// Filtered output pulses 
/////////////////////////////////////
always @(posedge clk) begin
  if (rst) begin
    usec_p <= 1'b0;
    msec_p <= 1'b0;
    sec_p <= 1'b0;
  end
  else begin
    usec_p <= tick_cntr_max;
    msec_p <= tick_cntr_max & usec_max;
    sec_p <= tick_cntr_max & msec_max & usec_max;
  end
end     

endmodule
