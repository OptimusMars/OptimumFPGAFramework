//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : Memcic
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : vmemcic_tb.sv
//-- created     : 30 апреля 2020 г. : 16:43:15	
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

module vmemcic_tb;
parameter         DVAL_PERIOD     = 32;
parameter         WIDTH_I         = 16;               // Input data Width
parameter         WIDTH_O         = 17;               // Input data Width
parameter         STAGES          = 10;               // CIC filter stages
parameter         MAX_DECIMATION  = 16;               // Maximum Decimation factor
parameter         RATES           = 4;                // Output sample rates
parameter integer DEC_ARR[RATES]  = {2, 4, 8, 16};    // Decimation factor array
parameter         WIDTH_S         = $clog2(RATES);    //

localparam HALFTICK = 5;


logic                      clk_i = '0;
logic                      rst_i;
logic                      data_val_i;
logic                      data_val_o;
logic [WIDTH_S-1:0]        dec_sel_i;

logic signed [WIDTH_I-1:0] data_i;
logic signed [WIDTH_O-1:0] data_o;

logic [$clog2(DVAL_PERIOD) - 1:0] dval_cnt;

initial forever #HALFTICK clk_i <= #HALFTICK ~clk_i;

assign data_val_i = dval_cnt == '0;


initial begin
  rst_i <= '0;
  @ (posedge clk_i);
  rst_i <= '1;
  @ (posedge clk_i);
  rst_i <= '0;
end

initial begin
  dec_sel_i <= 3;
end

vmemcic #(
  .WIDTH_I        (WIDTH_I),
  .WIDTH_O        (WIDTH_O),
  .STAGES         (STAGES),
  .MAX_DECIMATION (MAX_DECIMATION),
  .RATES          (RATES),
  .DEC_ARR        (DEC_ARR)
) vmemcic_instance (
  .clk_i        (clk_i),
  .rst_i        (rst_i),
  .dec_sel_i    (dec_sel_i),
  .data_i       (data_i),
  .data_val_i   (data_val_i),
  .data_val_o   (data_val_o),
  .data_o       (data_o),
  .error        (error)
);

sine_tb #(
  .DWIDTH     (WIDTH_I),
  .PHASE_MAX  (4096)
) sine_tb_instance (
  .clk_i      (clk_i),
  .rst_i      (rst_i),
  .clk_ena_i  (data_val_i),
  .sine_o     (data_i),
  .cos_o      ()
);


always_ff @ (posedge clk_i or posedge rst_i)
  if (rst_i) dval_cnt <= '0;
  else if (dval_cnt == DVAL_PERIOD - 1) dval_cnt <= '0;
  else dval_cnt <= dval_cnt + 1'b1;

endmodule // vmemcic_tb
