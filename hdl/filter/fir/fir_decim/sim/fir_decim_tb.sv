//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : FIR
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_ram_tb.sv
//-- created     : 14 марта 2020 г. : 17:35:09	
//-- author      : Martynov Ivan
//-- company     : Expert Electronix, Taganrog, Russia
//-- target      : [x] simulation  [x] synthesis
//-- technology  : [x] any
//-- tools & o/s : quartus 13.1 & windows 7
//-- dependency  :
//-------------------------------------------------------------------------------
//-- description : 
//-- 
//--
//-------------------------------------------------------------------------------
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fir_decim_tb;

parameter FILTER_ORDER        = 256;                  // Filter order 
parameter DECIMATION          = 8;                    // DECIMATION factor
parameter DATA_WIDTH          = 16;                   // Input data width
parameter COEF_WIDTH          = 20;                   // Filter coefficients width 
parameter USE_MEMORY_WRITE    = 0;                    // Use coefficients memory writing
parameter COEF_AWIDTH         = $clog2(FILTER_ORDER);
parameter COEF_FILE           = "fir_decim_coef.mif";
parameter OUT_WIDTH           = 17;
localparam HALFTICK           = 5;

logic                             clk_i;
logic                             rst_i;
logic signed [DATA_WIDTH - 1:0]   data_i;
logic                             data_val_i;
logic signed [OUT_WIDTH - 1:0]    data_o;
logic                             data_val_o;
logic [1:0]                       err_flg_o;
logic signed [DATA_WIDTH - 1:0]   sine_o;
logic signed [DATA_WIDTH - 1:0]   cos_o;

localparam WAIT_COMPUTE = FILTER_ORDER;
localparam PHASE_TIME = FILTER_ORDER/DECIMATION + 4;
localparam FILTER_TEST = 1;
localparam signed HEAVISIDE_MAX = 2**(DATA_WIDTH-1) - 1;
localparam signed HEAVISIDE_MIN = $signed(-(2**(DATA_WIDTH - 1) - 1));

initial begin
  clk_i <= '0;
  forever #HALFTICK clk_i <= #HALFTICK ~clk_i;
end

fir_decim_top #(
  .FILTER_ORDER     (FILTER_ORDER),
  .DECIMATION       (DECIMATION),
  .COEF_FILE        (COEF_FILE),
  .DATA_WIDTH       (DATA_WIDTH),
  .COEF_WIDTH       (COEF_WIDTH),
  .OUT_WIDTH        (OUT_WIDTH),
  .USE_COEF_WRITE   (0),
  .COEF_AWIDTH      (COEF_AWIDTH)
) fir_decim_top_instance (
  .clk_i            (clk_i),
  .rst_i            (rst_i),
  .data_i           (data_i),
  .data_val_i       (data_val_i),
  .coef_we_i        ('0),
  .coef_addr_i      ('0),
  .coef_data_i      ('0),
  .data_o           (data_o),
  .data_val_o       (data_val_o),
  .err_flg_o        (err_flg_o)
);

task reset(input int duration);
  data_i <= '0;
  data_val_i <= '0;
  rst_i <= '0;
  #100;
  @ (posedge clk_i);
  rst_i <= '1;
  repeat(duration) @ (posedge clk_i);
  rst_i <= '0;
endtask

task filter_start(int val, int wait_time);
  @ (posedge clk_i);
  data_i <= val;
  data_val_i <= '1;
  @ (posedge clk_i);
  data_val_i <= '0;
  data_i <= '0;
  repeat(wait_time) @ (posedge clk_i);
endtask

task filter_proceed(int wait_time);
  @ (posedge clk_i);
  data_val_i <= '1;
  @ (posedge clk_i);
  data_val_i <= '0;
  repeat(wait_time) @ (posedge clk_i);
endtask

initial begin
  reset(10);
  // First phase of computing
  if(FILTER_TEST == 0) begin
    filter_start(HEAVISIDE_MAX, PHASE_TIME);
    // Second phase 
    repeat(FILTER_ORDER*2) begin 
      filter_proceed(PHASE_TIME);
    end
  end
  else if(FILTER_TEST == 1) begin
    repeat(FILTER_ORDER) begin 
      filter_start(HEAVISIDE_MAX, PHASE_TIME);
    end
    repeat(FILTER_ORDER) begin 
      filter_start(HEAVISIDE_MIN, PHASE_TIME);
    end
  end
  else if(FILTER_TEST == 2) begin
    repeat(FILTER_ORDER*4) begin 
      filter_start(sine_o, PHASE_TIME);
    end
  end
  else begin
    $error("Unknown test");
  end
end

logic signed [OUT_WIDTH - 1:0]    data_max; 
logic signed [OUT_WIDTH - 1:0]    data_min;
logic signed [OUT_WIDTH - 1:0]    data_scaled;
logic sig_fault;

always_ff @ (posedge clk_i or posedge rst_i) begin
  if (rst_i) begin 
    data_max <= '0;
    data_min <= '0;
  end
  else begin
    data_max <= (data_o > data_max) ? data_o : data_max;
    data_min <= (data_o < data_min) ? data_o : data_min;
  end
end

sine_tb #(
  .DWIDTH     (DATA_WIDTH), 
  .PHASE_MAX  (256)
)
sine_tb_inst (
  .clk_i      (clk_i),
  .rst_i      (rst_i),
  .clk_ena_i  (data_val_i),
  .sine_o     (sine_o),
  .cos_o      (cos_o)
);


endmodule // fir_ram_tb