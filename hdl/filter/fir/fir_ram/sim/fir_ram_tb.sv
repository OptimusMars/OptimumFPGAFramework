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

module fir_ram_tb;

parameter FILTER_ORDER        = 256;      // Filter order 
parameter DATA_WIDTH          = 16;       // Input data width
parameter COEF_WIDTH          = 16;       // Filter coefficients width 
parameter PARALLEL            = 8;       // Parallel computing stages
parameter OUT_WIDTH           = 17;       // Output width
parameter COEF_AWIDTH         = $clog2(FILTER_ORDER);
parameter COEF_FILE           = "fir_ram_coef.mif";
localparam HALFTICK           = 5;
parameter PROCESSING_TYPE   = "LIMIT";              // Processing Type

logic                             clk_i;
logic                             rst_i;
logic signed [DATA_WIDTH - 1:0]   data_i;
logic                             data_val_i;
logic signed [OUT_WIDTH - 1:0]    data_o;
logic [1:0]                       err_flg_o;

localparam WAIT_COMPUTE = FILTER_ORDER/PARALLEL + 5;
localparam FILTER_TEST = 1;
localparam signed HEAVISIDE_MAX = 2**(DATA_WIDTH-1) - 1;
localparam signed HEAVISIDE_MIN = $signed(-(2**(DATA_WIDTH - 1) - 1));

initial begin
  clk_i <= '0;
  forever #HALFTICK clk_i <= #HALFTICK ~clk_i;
end

fir_ram_top #(
  .FILTER_ORDER     (FILTER_ORDER),
  .COEF_FILE        (COEF_FILE),
  .DATA_WIDTH       (DATA_WIDTH),
  .COEF_WIDTH       (COEF_WIDTH),
  .OUT_WIDTH        (OUT_WIDTH),
  .PARALLEL         (PARALLEL),
  .USE_COEF_WRITE   (0),
  .PROCESSING_TYPE  (PROCESSING_TYPE),
  .COEF_AWIDTH      (COEF_AWIDTH)
) fir_ram_top_instance (
  .clk_i            (clk_i),
  .rst_i            (rst_i),
  .data_i           (data_i),
  .data_val_i       (data_val_i),
  .coef_we_i        ('0),
  .coef_addr_i      ('0),
  .coef_data_i      ('0),
  .data_o           (data_o),
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
  if(FILTER_TEST == 0) begin
    filter_start(HEAVISIDE_MAX, WAIT_COMPUTE);
    repeat(FILTER_ORDER*2) begin 
      filter_proceed(WAIT_COMPUTE);
    end
  end
  else begin
    repeat(FILTER_ORDER*2) begin 
      filter_start(HEAVISIDE_MAX, WAIT_COMPUTE);
    end
  end
  
end


endmodule // fir_ram_tb