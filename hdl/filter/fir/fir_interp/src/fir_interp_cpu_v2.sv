//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_interp_cpu_v2.sv
//-- created     : 14 марта 2020 г. : 12:45:04	
//-- author      : Martynov Ivan
//-- company     : Expert Electronix, Taganrog, Russia
//-- target      : [x] simulation  [x] synthesis
//-- technology  : [x] any
//-- tools & o/s : quartus 13.1 & windows 7
//-- dependency  :
//-------------------------------------------------------------------------------
//-- description : FIR CPU
//-- 
//--
//-------------------------------------------------------------------------------
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fir_interp_cpu_v2
#(
  parameter FILTER_ORDER      = 256,
  parameter INTERPOLATION     = 32,
  parameter COEF_FILE         = "fir_interp.mif", 
  parameter DATA_WIDTH        = 16,
  parameter COEF_WIDTH        = 16,
  parameter OUT_WIDTH         = 16,
  parameter PROCESSING_TYPE   = "LIMIT",
  parameter COEF_AWIDTH       = $clog2(FILTER_ORDER)
)
(
  input                               clk_i,
  input                               rst_i,
  
  input signed [DATA_WIDTH - 1:0]     data_i,     // Input data sample
  input                               data_val_i, // Filter start computing 
  
  // Coefficients write signal
  input                               coef_we_i,          
  input [COEF_AWIDTH - 1:0]           coef_addr_i,
  input [COEF_WIDTH - 1:0]            coef_data_i,
  
  output signed [OUT_WIDTH - 1:0]     data_o,             // Output result
  output                              data_val_o,         // Output data valid
  
  output logic [1:0]                  err_flg_o
);

localparam ERR_DVAL_FAST        = 2'h1;
localparam ERR_DATA_LIMITED     = 2'h2;

localparam PHASE_STEP = FILTER_ORDER/INTERPOLATION;
localparam ACC_WIDTH = COEF_WIDTH + DATA_WIDTH + 4;  

logic                               mult_ena;                // Enable multiplier/accumulator vector

logic                               mult_ena_d;

logic                               addr_ena;
logic [ACC_WIDTH - 1:0]             accum;

logic [$clog2(PHASE_STEP) - 1:0]    data_addr;
logic [$clog2(PHASE_STEP) - 1:0]    write_pointer;
logic [$clog2(PHASE_STEP) - 1:0]    write_pointer_old;
logic [$clog2(PHASE_STEP) - 1:0]    cnt_compute;
logic [$clog2(INTERPOLATION) :0]    phase;
logic                               phase_fault;
logic                               write_poiter_max;

logic [$clog2(PHASE_STEP) - 1:0]    read_poiter; 
logic                               read_pointer_zero;
logic [DATA_WIDTH - 1:0]            data_q;

logic [$clog2(FILTER_ORDER) - 1:0]  coef_addr;
logic [COEF_WIDTH - 1:0]            coef_q;

logic signed [OUT_WIDTH - 1:0]      data_o_l;
logic signed [OUT_WIDTH - 1:0]      data_o_r;
logic                               data_limited_o;
logic                               is_precompute_s;
logic                               is_wait_0_s;
logic                               dava_val_o_r;

typedef logic [$clog2(FILTER_ORDER) - 1:0]  coef_addr_t;
typedef logic [$clog2(PHASE_STEP) - 1:0]    read_poiter_t; 

always_comb 
  data_addr <= data_val_i ? write_pointer : read_poiter;

// Memory for input data
ram_1port #(
  .DWIDTH     (DATA_WIDTH),
  .WORDS      (PHASE_STEP)
) ram_1port_instance (
  .address    (data_addr),
  .clock      (clk_i),
  .data       (data_i),
  .wren       (data_val_i),
  .q          (data_q)
);

// Memory for coeficients
ram_2port #(
  .DWIDTH     (COEF_WIDTH),
  .WORDS      (1 << $clog2(FILTER_ORDER)),
  .INIT_FILE  (COEF_FILE)
) ram_2port_instance (
  .clock        (clk_i),
  .data_a       (coef_data_i),
  .address_a    (coef_addr_i),
  .wren_a       (coef_we_i),
  .q_a          (),
  
  
  .data_b       ('0),
  .address_b    (coef_addr),
  .wren_b       ('0),
  .q_b          (coef_q)
);  

// FIR multiplier accumulator
fir_ram_mult_acc #(
  .DATA_WIDTH   (DATA_WIDTH),
  .COEF_WIDTH   (COEF_WIDTH),
  .ACC_WIDTH    (ACC_WIDTH)
) 
fir_ram_mult_acc_instance (
  .clk_i    (clk_i),
  .rst_i    (rst_i),
  .clr_i    (is_precompute_s),
  .ena_i    (mult_ena),
  .data_i   (data_q),
  .coef_i   (coef_q),
  .acc_o    (accum)
);

fir_ram_out_processor #(
  .IWIDTH   (ACC_WIDTH),
  .OWIDTH   (OUT_WIDTH),
  .SHIFT    (COEF_WIDTH),  // Divide factor need to be less by interpolation factor (because of 31 zeros in input)
  .TYPE     (PROCESSING_TYPE)
) fir_ram_out_processor_instance (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .data_i         (accum),
  .data_o         (data_o_l),
  .data_limited_o (data_limited_o)
);

enum logic [1:0] {IDLE_S = '0,
                  PRE_COMPUTE_S,    // Precompute state
                  COMPUTE_S,        // Compute state
                  WAIT_0_S          // Dummy waiting
                  } fir_interp_cpu_fsm;

always_ff @ (posedge clk_i or posedge rst_i) begin
  if(rst_i) fir_interp_cpu_fsm <= IDLE_S;
  else begin
    case(fir_interp_cpu_fsm) /* synthesis syn_encoding = "safe, one-hot" */
      IDLE_S: begin
        if(data_val_i) fir_interp_cpu_fsm <= PRE_COMPUTE_S;
      end
      PRE_COMPUTE_S: fir_interp_cpu_fsm <= COMPUTE_S;
      COMPUTE_S: begin
        if(cnt_compute == PHASE_STEP - 1)    // Interpolation ends
          fir_interp_cpu_fsm <= WAIT_0_S;
      end
      WAIT_0_S: begin 
        if(phase == INTERPOLATION - 1) fir_interp_cpu_fsm <= IDLE_S;
        else fir_interp_cpu_fsm <= PRE_COMPUTE_S;
      end
      default: fir_interp_cpu_fsm <= IDLE_S;
    endcase
  end
end

assign is_precompute_s  = fir_interp_cpu_fsm == PRE_COMPUTE_S;
assign is_wait_0_s      = fir_interp_cpu_fsm == WAIT_0_S;

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) dava_val_o_r <= '0;
  else dava_val_o_r <= is_wait_0_s;

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) data_o_r <= '0;
  else if (is_wait_0_s) data_o_r <= data_o_l;

assign write_poiter_max = write_pointer == PHASE_STEP - 1;
always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) begin 
    write_pointer <= '0;
    write_pointer_old <= '0;
  end
  else if (data_val_i) begin
    write_pointer_old <= write_pointer;
    write_pointer <= write_poiter_max ? '0 : (write_pointer + 1'b1);
  end
end

// Phase of computing
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) phase <= '0;
  else if (data_val_i)      phase <= '0;
  else if (is_precompute_s) phase <= phase + 1'b1;

// Polyphase compute filter counter
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) cnt_compute <= '0;
  else if (is_precompute_s) cnt_compute <= '0;
  else if (fir_interp_cpu_fsm == COMPUTE_S) 
    cnt_compute <= cnt_compute + 1'b1;

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) addr_ena <= '0;
  else if (fir_interp_cpu_fsm == COMPUTE_S) addr_ena <= '1;
  else addr_ena <= '0;

// Enabling multiplication and accumulation
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) mult_ena <= '0;
  else mult_ena <= addr_ena;

// Memory address summer
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) coef_addr <= '0;
  else if (is_precompute_s) coef_addr <= phase;
  else if (fir_interp_cpu_fsm == COMPUTE_S) 
    coef_addr <= coef_addr + coef_addr_t'(INTERPOLATION);

// Data reader logic
assign read_pointer_zero = read_poiter == '0;
always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) read_poiter <= '0;
  else if (is_precompute_s) 
    read_poiter <= write_pointer_old;
  else if (fir_interp_cpu_fsm == COMPUTE_S) begin
    read_poiter <= read_pointer_zero ?  read_poiter_t'(PHASE_STEP - 1) : 
                                        read_poiter - 1'b1;
  end
end

// Error flag processing
always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    err_flg_o <= '0;
  end
  else begin 
    if(fir_interp_cpu_fsm == IDLE_S)  err_flg_o <= '0;
    else if(data_val_i)               err_flg_o <= err_flg_o | ERR_DVAL_FAST;
    else if(data_limited_o)           err_flg_o <= err_flg_o | ERR_DATA_LIMITED;
    else                              err_flg_o <= err_flg_o;
  end
end

assign data_o       = data_o_r;
assign data_val_o   = dava_val_o_r;

endmodule // fir_interp_cpu_v2
