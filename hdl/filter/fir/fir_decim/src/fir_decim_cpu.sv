//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_decim_cpu.sv
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

module fir_decim_cpu
#(
  parameter FILTER_ORDER      = 256,
  parameter DECIMATION        = 32,
  parameter COEF_FILE         = "fir_decim.mif", 
  parameter DATA_WIDTH        = 16,
  parameter COEF_WIDTH        = 16,
  parameter OUT_WIDTH         = 16,
  parameter PROCESSING_TYPE   = "TRUNC",
  parameter COEF_AWIDTH       = $clog2(FILTER_ORDER)
)
(
  input                               clk_i,
  input                               rst_i,
  
  input signed [DATA_WIDTH - 1:0]     data_i,       // Input data sample
  input                               data_val_i,   // Filter start computing 
  
  // Coefficients write signal
  input                               coef_we_i,          
  input [COEF_AWIDTH - 1:0]           coef_addr_i,
  input [COEF_WIDTH - 1:0]            coef_data_i,
  
  output signed [OUT_WIDTH - 1:0]     data_o,       // Output result
  output logic                        data_val_o,   // Output data valid
  
  output logic [1:0]                  err_flg_o
  
);

localparam ERR_DVAL_REQ         = 2'h1;         // Dval is too fast
localparam ERR_DATA_LIMIT       = 2'h2;         // Output data is limited

localparam PHASE_STEP = FILTER_ORDER/DECIMATION;      // Phase pointer increment
localparam DELAY_ORDER = FILTER_ORDER + DECIMATION;   // Signal Delay Value (Delay is more than Filter order on decimation factor)
localparam ACC_WIDTH = COEF_WIDTH + DATA_WIDTH + 4;  
localparam ACC_WIDTH_DEC = ACC_WIDTH + 2;
localparam PWIDTH = $clog2(DELAY_ORDER);             // Pointer width
localparam PHWIDTH = $clog2(PHASE_STEP);              // Phase counter width
localparam DEC_WIDTH = $clog2(DECIMATION);

logic                             mult_ena;     // Enable multiplier/accumulator vector
logic [ACC_WIDTH - 1:0]           accum;

logic                               accum_clr;     // Decimator accumulator clear
logic                               mult_ena_r;    
logic                               accum_ena;
logic signed [ACC_WIDTH_DEC - 1:0]  accum_o;

logic [PWIDTH - 1:0]              data_addr;
logic [PWIDTH - 1:0]              write_pointer;
logic [PWIDTH - 1:0]              write_pointer_next;
logic [PHWIDTH - 1:0]             cnt_compute;
logic [DEC_WIDTH - 1 :0]          phase;        // Phase of decimation

logic                             phase_zero;      
logic                             write_poiter_max;

logic [PWIDTH - 1:0]              read_pointer;  
logic [PWIDTH - 1:0]              read_pointer_next;  
logic signed [OUT_WIDTH - 1:0]    data_o_r;
logic signed [OUT_WIDTH - 1:0]    data_o_l;

logic [DATA_WIDTH - 1:0]            data_q;           

logic [$clog2(FILTER_ORDER) - 1:0]  coef_addr;
logic [$clog2(FILTER_ORDER) - 1:0]  coef_addr_pre;
logic [COEF_WIDTH - 1:0]            coef_q;
logic                               compute_ena;
logic                               data_limited_o;

typedef logic [$clog2(FILTER_ORDER) - 1:0] coef_addr_t;
typedef logic [PWIDTH - 1:0] data_pointer_t; 
typedef logic [DEC_WIDTH - 1 :0] phase_t;

always_comb 
  data_addr <= data_val_i ? write_pointer : read_pointer;

// Memory for input data
ram_1port #(
  .DWIDTH     (DATA_WIDTH),
  .WORDS      (DELAY_ORDER)
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
  .WORDS      (FILTER_ORDER),
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
  .clr_i    (data_val_i),
  .ena_i    (mult_ena),
  .data_i   (data_q),
  .coef_i   (coef_q),
  .acc_o    (accum)
);

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) mult_ena_r <= '0;
  else mult_ena_r <= mult_ena;

assign accum_clr = data_val_o;

edet #("NEG") edet0 (clk_i, mult_ena_r, accum_ena);

// Decimator accumulator
fir_ram_accum #(
  .DWIDTH (ACC_WIDTH),
  .ACWIDTH(ACC_WIDTH_DEC)
) fir_ram_accum (
  .clk_i      (clk_i),
  .rst_i      (rst_i),
  .clr_i      (accum_clr),
  .clk_ena_i  (accum_ena),
  .data_i     (accum),
  .accum_o    (accum_o)
);

// Output data processor
fir_ram_out_processor #(
  .IWIDTH   (ACC_WIDTH_DEC),
  .OWIDTH   (OUT_WIDTH),
  .SHIFT    (COEF_WIDTH),
  .TYPE     (PROCESSING_TYPE)
) fir_ram_out_processor_instance (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .data_i         (accum_o),
  .data_o         (data_o_l),
  .data_limited_o (data_limited_o)
);

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) data_o_r <= '0;
  else if (data_val_o) data_o_r <= data_o_l;
  
enum logic [2:0] {IDLE_S = '0,
                  COMPUTE_S,
                  WAIT0_S,
                  WAIT1_S
                  } fir_decim_cpu_fsm;

always_ff @ (posedge clk_i or posedge rst_i) begin
  if(rst_i) fir_decim_cpu_fsm <= IDLE_S;
  else begin
    case(fir_decim_cpu_fsm)
      IDLE_S: begin
        if(data_val_i) fir_decim_cpu_fsm <= COMPUTE_S;
      end
      COMPUTE_S: begin
        if(cnt_compute == PHASE_STEP - 1)
          fir_decim_cpu_fsm <= WAIT0_S;
      end
      WAIT0_S: begin
        fir_decim_cpu_fsm <= WAIT1_S;
      end
      WAIT1_S: begin
        fir_decim_cpu_fsm <= IDLE_S;
      end
      default: fir_decim_cpu_fsm <= IDLE_S;
    endcase
  end
end

// Polyphase compute filter counter
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) cnt_compute <= '0;
  else if (data_val_i) cnt_compute <= '0;
  else if (fir_decim_cpu_fsm == COMPUTE_S) 
    cnt_compute <= cnt_compute + 1'b1;

// Delay compute signal 

assign compute_ena = fir_decim_cpu_fsm == COMPUTE_S;

delay #(1, 2) 
delay_inst (
  .clk_i      (clk_i), 
  .rst_i      (rst_i), 
  .clk_en_i   ('1), 
  .data_i     (compute_ena), 
  .delay_o    (mult_ena), 
  .delay_taps ()
);

// Memory address summer
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) coef_addr <= '0;
  else if (data_val_i) coef_addr <= phase;
  else if (fir_decim_cpu_fsm == COMPUTE_S) 
    coef_addr <= coef_addr + coef_addr_t'(DECIMATION);

// Data reader logic
always_comb begin
  if(read_pointer < DECIMATION)
    read_pointer_next <= data_pointer_t'(FILTER_ORDER) + read_pointer;
  else 
    read_pointer_next <= read_pointer - data_pointer_t'(DECIMATION);
  
  if(write_pointer < DECIMATION)
    write_pointer_next <= data_pointer_t'(FILTER_ORDER) + write_pointer;
  else 
    write_pointer_next <= write_pointer - data_pointer_t'(DECIMATION);

end

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i)
    read_pointer <= '0;
  else if (data_val_i) begin
    if(phase_zero) read_pointer <= write_pointer;
    else read_pointer <= write_pointer_next;
  end
  else begin
    read_pointer <= read_pointer_next;
  end
end

assign write_poiter_max = write_pointer == DELAY_ORDER - 1;
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) write_pointer <= '0;
  else if (data_val_i) 
    write_pointer <= write_poiter_max ? '0 : (write_pointer + 1'b1);

// Phase of computing
assign phase_zero = phase == '0;
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) phase <= '0;
  else if (data_val_i && phase_zero) phase <= phase_t'(DECIMATION - 1);
  else if (data_val_i) phase <= phase - 1'b1;
  

// Error flag processing
always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    err_flg_o <= '0;
  end
  else begin 
    if(fir_decim_cpu_fsm != IDLE_S && data_val_i)
      err_flg_o <= err_flg_o | ERR_DVAL_REQ;
    else if (data_limited_o)
      err_flg_o <= err_flg_o | ERR_DATA_LIMIT;
  end
end

assign data_val_o = phase_zero && data_val_i;
assign data_o = data_o_r;

endmodule // fir_decim_cpu
