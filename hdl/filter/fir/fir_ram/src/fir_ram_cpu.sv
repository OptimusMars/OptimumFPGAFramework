//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_ram_cpu.sv
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

module fir_ram_cpu
#(
  parameter FILTER_ORDER      = 256,
  parameter DATA_WIDTH        = 16,
  parameter COEF_WIDTH        = 16,
  parameter PARALLEL          = 4,
  parameter OUT_WIDTH         = 16,
  parameter PROCESSING_TYPE   = "LIMIT",
  parameter COEF_AWIDTH       = $clog2(FILTER_ORDER)
)
(
  input                               clk_i,
  input                               rst_i,
  
  input                               data_val_i,         // Filter start computing 
  
  output signed [OUT_WIDTH - 1:0]     data_o,             // Output result
  
  output                              data_ram_rd_o,      // Read data from memory
  input [DATA_WIDTH*PARALLEL-1:0]     data_ram_i,         // Readed data
  
  output  [COEF_AWIDTH*PARALLEL-1:0]  coef_read_addr_o,   // Coeficients Read address
  input  [COEF_WIDTH*PARALLEL-1:0]    coef_read_data_i,   // Coeficients
  output logic [1:0]                  err_flg_o
);

localparam ERR_DVAL_FAST        = 2'h1;
localparam ERR_DATA_LIMIT       = 2'h2;

localparam OWIDTH = $clog2(FILTER_ORDER);             // Filter order counter width
localparam ITERATION = FILTER_ORDER / PARALLEL;       // Filter computation iteration
localparam IWIDTH = $clog2(ITERATION);                // Iteration width
localparam ACC_WIDTH = COEF_WIDTH + DATA_WIDTH + 4;  
localparam ACC_WIDTH_ALL = ACC_WIDTH + 2;

initial begin
  if ( COEF_AWIDTH !=  $clog2(FILTER_ORDER))
    $error("COEF_WIDTH cannot be overwritten");
end

logic                              mult_ena;                // Enable multiplier/accumulator vector
logic                              mult_ena_d = '0;

logic [ACC_WIDTH*PARALLEL - 1:0]   accum;       // Accumulator vector
logic signed [ACC_WIDTH_ALL-1:0]   accum_all;   // 
logic                              accum_ena;

logic [IWIDTH - 1:0]               cnt_iteration;           // Iteration counter
logic                              addr_ena;
logic [COEF_AWIDTH*PARALLEL-1:0]   coef_read_addr;

logic                              data_limited_o;

typedef logic [COEF_AWIDTH - 1:0] coef_read_addr_t;

// FIR multiplier accumulator

fir_ram_mult_acc #(
  .DATA_WIDTH   (DATA_WIDTH),
  .COEF_WIDTH   (COEF_WIDTH),
  .ACC_WIDTH    (ACC_WIDTH)
) 
fir_ram_mult_acc_instance [PARALLEL-1:0] (
  .clk_i    (clk_i),
  .rst_i    (rst_i),
  .clr_i    (data_val_i),
  .ena_i    (mult_ena_d),
  .data_i   (data_ram_i),
  .coef_i   (coef_read_data_i),
  .acc_o    (accum)
);

// Parallel adder needs to summ all accumulator outputs
adder_parallel #(
  .WIDTH_I        (ACC_WIDTH),
  .INPUTS         (PARALLEL),
  .PEPRESENTATION ("SIGNED"),
  .PIPELINE       (1),
  .WIDTH_O        (ACC_WIDTH_ALL)
) adder_parallel_instance (
  .clock          (clk_i),
  .reset          (rst_i),
  .clken          (accum_ena),  
  .data           (accum),
  .result         (accum_all)
);

fir_ram_out_processor #(
  .IWIDTH   (ACC_WIDTH_ALL),
  .OWIDTH   (OUT_WIDTH),
  .SHIFT    (COEF_WIDTH),
  .TYPE     (PROCESSING_TYPE)
) fir_ram_out_processor_instance (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .data_i         (accum_all),
  .data_o         (data_o),
  .data_limited_o (data_limited_o)  
);

enum logic [2:0] {  IDLE_S = '0,    // IDLE State
                    COMPUTATION_S,  // Computation state
                    WAIT0_S,        // WAIT
                    WAIT1_S,        // WAIT
                    WAIT2_S,        // WAIT
                    WAIT3_S,        // WAIT
                    READY_S
                  } fir_cpu_fsm;  // FSM

always_ff @ (posedge clk_i or posedge rst_i) begin
  if(rst_i) fir_cpu_fsm <= IDLE_S;
  else begin
    case(fir_cpu_fsm) /* synthesis syn_encoding = "safe, one-hot" */
      IDLE_S: begin
        if(data_val_i) 
          fir_cpu_fsm <= COMPUTATION_S;
      end
      COMPUTATION_S: begin
        if(cnt_iteration == ITERATION - 1)
          fir_cpu_fsm <= WAIT0_S;
      end
      WAIT0_S: fir_cpu_fsm <= WAIT1_S;
      WAIT1_S: fir_cpu_fsm <= WAIT2_S;
      WAIT2_S: fir_cpu_fsm <= WAIT3_S;
      WAIT3_S: fir_cpu_fsm <= READY_S;
      READY_S: fir_cpu_fsm <= IDLE_S;
      default: fir_cpu_fsm <= IDLE_S;
    endcase
  end
end

always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) addr_ena <= '0;
  else if (fir_cpu_fsm == COMPUTATION_S) addr_ena <= '1;
  else addr_ena <= '0;

// Validation of differrent paralles stages
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) mult_ena <= '0;
  else mult_ena <= addr_ena;
  
always_ff @ (posedge clk_i) mult_ena_d <= mult_ena;

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) coef_read_addr <= '0;
  else begin
    for (int i = 0; i < PARALLEL; i++) begin
      if(data_val_i)
        coef_read_addr[COEF_AWIDTH*i +: COEF_AWIDTH] <= coef_read_addr_t'(i*ITERATION);
      else if (addr_ena)
        coef_read_addr[COEF_AWIDTH*i +: COEF_AWIDTH] <= 
            coef_read_addr[COEF_AWIDTH*i +: COEF_AWIDTH] + 1'b1;
    end
  end
end

// Iteration counter
always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) cnt_iteration <= '0;
  else if (fir_cpu_fsm == COMPUTATION_S)  cnt_iteration <= cnt_iteration + 1'b1;
  else cnt_iteration <= '0;

// Error flag processing
// Error occures if new data arrived until computing ends
always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) err_flg_o <= '0;
  else if (data_val_i && fir_cpu_fsm != IDLE_S) 
    err_flg_o <= err_flg_o | ERR_DVAL_FAST;
  else if (data_limited_o)
    err_flg_o <= err_flg_o | ERR_DATA_LIMIT;
end

always_comb
  accum_ena <= fir_cpu_fsm == READY_S;

assign coef_read_addr_o   = coef_read_addr;
assign data_ram_rd_o      = addr_ena;

endmodule // fir_ram_cpu
