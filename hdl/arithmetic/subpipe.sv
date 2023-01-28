// Two pipeline substractor - very fast
module subpipe  #(
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