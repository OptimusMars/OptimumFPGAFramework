// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

// synthesis VERILOG_INPUT_VERSION SYSTEM_VERILOG_2005 
module vmemcic
#(
  parameter         WIDTH_I         = 16,               // Input data Width
  parameter         WIDTH_O         = WIDTH_I,          // Output data Width
  parameter         STAGES          = 10,               // CIC filter stages
  parameter         MAX_DECIMATION  = 16,               // Maximum Decimation factor
  parameter         RATES           = 4,                // Output sample rates
  parameter integer DEC_ARR[RATES]  = '{2, 4, 8, 16},    // Decimation factor array
  // Localparam
  parameter         WIDTH_S         = $clog2(RATES)
)
(
  input                               clk_i,
  input                               rst_i, 
  
  input signed [WIDTH_I-1:0]          data_i,
  input                               data_val_i,
  input [WIDTH_S-1:0]                 dec_sel_i, 
  
  output logic                        data_val_o,
  output logic  signed [WIDTH_O-1:0]  data_o,
  
  output logic                        error
);

localparam AWIDTH     = $clog2(STAGES);
localparam DIV_WIDTH  = $clog2(MAX_DECIMATION);

integer ii;
localparam WIDTH_GAIN = WIDTH_I + STAGES * $clog2(MAX_DECIMATION);    // Maximum output width
initial begin
  if(STAGES < 2) $fatal("STAGES parameter must be greater than 2");
  if((MAX_DECIMATION < 2)) $fatal("DECIMATION must be greater than 2");
  if(WIDTH_O > WIDTH_GAIN) $fatal("WIDTH_O exceed WIDTH_GAIN");
  ii = 0;
  for (ii = 0; ii < RATES; ii++) begin
    if(DEC_ARR[ii] > MAX_DECIMATION)
      $fatal("MAX_DECIMATION parameter set wrong");
  end
end
 
//------------------------------------------------------------------------------
//                             control regs
//------------------------------------------------------------------------------
reg [2:0] state;            // State machine
wire is_comb = state[2];    // Need to compute comb stages

logic  [AWIDTH - 1:0]         rdaddress;
logic  [AWIDTH - 1:0]         wraddress;
logic                         wren;
logic  [DIV_WIDTH - 1:0]      sample_no;
logic                         data_val_o_pre;

typedef logic  [AWIDTH - 1:0] addr_t;

//------------------------------------------------------------------------------
//                             computations
//------------------------------------------------------------------------------
logic signed [WIDTH_GAIN - 1:0] work_reg;
logic signed [WIDTH_GAIN - 1:0] ram_output;
wire  signed [WIDTH_GAIN - 1:0] new_intg_value = work_reg + ram_output;        // New integrator value
wire  signed [WIDTH_GAIN - 1:0] new_comb_value = work_reg - ram_output;        // New comb value
wire  signed [WIDTH_GAIN - 1:0] ram_input = is_comb ? work_reg : new_intg_value;

integer deci_array[RATES - 1:0];
integer deci;
logic signed [WIDTH_O-1:0] sel_array[RATES - 1:0];

genvar i;
generate 
  for (i = 0; i < RATES; i++) begin : width_compute_for
    assign deci_array[i] = DEC_ARR[i] - 1;
    vmemcic_sel #(WIDTH_GAIN, WIDTH_I, WIDTH_O, STAGES, DEC_ARR[i]) 
    vmemcic_sel_inst (work_reg, sel_array[i]);
  end
endgenerate

assign deci = deci_array[dec_sel_i];      // Decimation mux out

//------------------------------------------------------------------------------
//                                 loop
//------------------------------------------------------------------------------
always @(posedge clk_i or posedge rst_i) begin
  if(rst_i) begin
    state       <= '0;
    sample_no   <= '0;
    rdaddress   <= '0;
    wraddress   <= '0;
    wren        <= '0;
    data_val_o  <= '0;
  end
  else begin
    case (state)
    //integrators
    0: begin
      data_val_o <= '0;
      if (data_val_i) begin
        work_reg  <= data_i;
        rdaddress <= addr_t'(1);
        state     <= 3'd1;
      end
    end
    1: begin
      rdaddress <= addr_t'(2);
      wraddress <= '0;
      wren      <= '1;
      state     <= 3'd2;
    end
    2: begin
      work_reg <= new_intg_value;
      if (wraddress < (STAGES-1)) begin
        rdaddress <= rdaddress + 1'b1;
        wraddress <= wraddress + 1'b1;
      end
      else begin
        wren <= '0;
        rdaddress <= '0;
        if (sample_no < deci) begin
          sample_no <= sample_no + 1'b1;
          state     <= 3'd0;
        end
        else begin
          sample_no <= '0;
          state     <= 3'd4;
        end
      end
    end
    //combs
    //-----
    4: begin
      rdaddress <= addr_t'(1);
      state     <= 3'd5;
    end
    5: begin
      rdaddress <= addr_t'(2);
      wraddress <= '0;
      wren      <= '1;
      state     <= 3'd6;
    end
    6: begin
      work_reg <= new_comb_value;
      if (wraddress < (STAGES-1)) begin
        rdaddress <= rdaddress + 1'b1;
        wraddress <= wraddress + 1'b1;
      end
      else begin
        wren    <= '0;
        state   <= 3'd7;
      end
    end
    7:begin
      data_o      <= sel_array[dec_sel_i];
      data_val_o  <= '1;
      rdaddress   <= '0;
      state       <= '0;
    end
    endcase
  end
end

//------------------------------------------------------------------------------
//                                    RAM
//------------------------------------------------------------------------------
//ram output data are available 3 cycles after the address counter change
vmemcic_ram #(
  .DWIDTH   (WIDTH_GAIN),
  .AWIDTH   (AWIDTH + 1)   // Additional bit need to getting comb flag
)
vmemcic_ram_inst(
  .clock        (clk_i),
  .rdaddress    ({is_comb, rdaddress}),
  .wraddress    ({is_comb, wraddress}),
  .wren         (wren),
  .data         (ram_input),
  .q            (ram_output)
  );



// Error flag if samples incoming too fast
always @ (posedge clk_i)
  if (state == 0) error <= '0;
  else if(data_val_i) error <= '1;

endmodule

