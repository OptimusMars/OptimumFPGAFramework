// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on
// synthesis VERILOG_INPUT_VERSION SYSTEM_VERILOG_2005 
module memcic
#(
  parameter WIDTH_I     = 24,       // Input data Width
  parameter WIDTH_O     = WIDTH_I,  // Input data Width
  parameter STAGES      = 10,       // CIC filter stages
  parameter DECIMATION  = 4         // Decimation factor
)
(
  input                           clk_i,
  input                           rst_i, 
  
  input signed [WIDTH_I-1:0]      data_i,
  input                           data_val_i,
  
  output reg                      data_val_o,
  output reg signed [WIDTH_O-1:0] data_o,
  
  output reg                      error
);

localparam AWIDTH     = $clog2(STAGES);
localparam DIV_WIDTH  = $clog2(DECIMATION);
localparam WIDTH_GAIN = WIDTH_I + STAGES * $clog2(DECIMATION);
 
//------------------------------------------------------------------------------
//                             control regs
//------------------------------------------------------------------------------
reg [2:0] state;
wire is_comb = state[2];

reg [AWIDTH - 1:0]    rdaddress;
reg [AWIDTH - 1:0]    wraddress;
reg                   wren;
reg [DIV_WIDTH - 1:0] sample_no;

typedef reg [AWIDTH - 1:0] addr_t;

//------------------------------------------------------------------------------
//                             computations
//------------------------------------------------------------------------------
reg signed [WIDTH_GAIN - 1:0] work_reg;
wire signed [WIDTH_GAIN - 1:0] ram_output;
wire signed [WIDTH_GAIN - 1:0] new_intg_value = work_reg + ram_output;        // New integrator value
wire signed [WIDTH_GAIN - 1:0] new_comb_value = work_reg - ram_output;        // New comb value
wire signed [WIDTH_GAIN - 1:0] ram_input = is_comb ? work_reg : new_intg_value;


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
    data_o      <= '0;
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
        if (sample_no < (DECIMATION-1)) begin
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
      // data_o      <= work_reg[WIDTH_GAIN - 1:WIDTH_GAIN - WIDTH_O] + work_reg[WIDTH_O]; 
      data_o      <= work_reg[WIDTH_GAIN - 1:WIDTH_GAIN - WIDTH_O]; 
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
memcic_ram #(
  .DWIDTH   (WIDTH_GAIN),
  .AWIDTH   (AWIDTH + 1)   // Additional bit need to getting comb flag
)
memcic_ram_inst(
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

