//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- project     : Project
//-- version     : 1.0
//-------------------------------------------------------------------------------
//-- file name   : fir_ram_data_ram.sv
//-- created     : 14 марта 2020 г. : 11:09:41	
//-- author      : Martynov Ivan
//-- company     : Expert Electronix, Taganrog, Russia
//-- target      : [x] simulation  [x] synthesis
//-- technology  : [x] any
//-- tools & o/s : quartus 13.1 & windows 7
//-- dependency  :
//-------------------------------------------------------------------------------
//-- description : FIR data memory
//-- 
//--
//-------------------------------------------------------------------------------

// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module fir_ram_data_ram
#(
  parameter DATA_WIDTH  = 16,
  parameter ORDER       = 256,
  parameter PORTS       = 4
)
(
  input                         clk_i,
  input                         rst_i,
  
  input                         data_we_i,    // Write new data sample
  input [DATA_WIDTH-1:0]        data_i,       // Data sample
  
  input                         data_rd_i,    // Read data from memory
  output [DATA_WIDTH*PORTS-1:0] data_o        // Readed data
    
);

localparam PWIDTH = $clog2(ORDER);      // Pointer width
localparam DEPTH = 1 << PWIDTH;
localparam ITERATION = ORDER/PORTS;     // Iteration count
localparam RAM_COUNT = (PORTS % 2 ) ? PORTS/2 + 1 : PORTS/2;    // Dual port ram count

logic [PWIDTH-1:0]          write_pointer;
logic                       write_max;
logic [PWIDTH-1:0]          read_pointer [PORTS-1:0]; // Read pointers
logic [PWIDTH-1:0]          read_pointer_inc [PORTS:0]; // Read pointers

typedef logic [PWIDTH-1:0]  read_pointer_t;

logic [DATA_WIDTH*PORTS-1:0]  data_out;

initial begin
  for (int i = 0; i <= PORTS; i++) begin
    read_pointer_inc[i] <= '0;
  end
end


// Memories for storing signal samples in parallel
genvar j;
generate 
if(PORTS == 1) begin
  logic [PWIDTH-1:0]        ram_address;
  logic [DATA_WIDTH - 1:0]  ram_q;
  always_comb
    ram_address <= data_we_i ? write_pointer : read_pointer_inc[0];
  ram_1port #(
    .DWIDTH     (DATA_WIDTH),
    .WORDS      (DEPTH)
  ) ram_1port_instance (
    .address    (ram_address),
    .clock      (clk_i),
    .data       (data_i),
    .wren       (data_we_i),
    .q          (ram_q)
  );
  assign data_out = ram_q;
end
else begin
  logic [PWIDTH*RAM_COUNT*2 - 1:0]        ram_address;
  logic [DATA_WIDTH*RAM_COUNT*2 - 1:0]    ram_q;
  
  always_comb begin
    for (int i = 0; i < RAM_COUNT*2; i++) begin
      ram_address[i*PWIDTH +: PWIDTH] <= data_we_i ? write_pointer : 
                                                     read_pointer_inc[i]; 
    end
  end
  
  for (j = 0; j < RAM_COUNT; j++) begin : dp_ram_processing
    ram_2port #(
      .DWIDTH     (DATA_WIDTH),
      .WORDS      (DEPTH)
    ) ram_2port_instance (
    .address_a    (ram_address[j*2*PWIDTH +: PWIDTH]),
    .address_b    (ram_address[(j*2+1)*PWIDTH +: PWIDTH]),
    .clock        (clk_i),
    .data_a       (data_i),
    .data_b       (),
    .wren_a       (data_we_i),
    .wren_b       (),
    .q_a          (ram_q[j*2*DATA_WIDTH +:DATA_WIDTH]),
    .q_b          (ram_q[(j*2+1)*DATA_WIDTH +:DATA_WIDTH])
    );
  end
  assign data_out = ram_q[DATA_WIDTH*PORTS-1:0];
end
endgenerate

assign data_o = data_out;
assign write_max = write_pointer == ORDER - 1;    // Write pointer unrolling flag

// Processing write pointer
always_ff @ (posedge clk_i or posedge rst_i)
  if ( rst_i ) write_pointer <= '0;
  else if (write_max &&  data_we_i) write_pointer <= '0;
  else if (data_we_i) write_pointer <= write_pointer + 1'b1;


always_ff @ (posedge clk_i or posedge rst_i) begin
  if( rst_i ) begin
    for (int i = 0; i < PORTS; i++) begin
      read_pointer[i] <= read_pointer_t'((PORTS - i)*ITERATION);    // Avoid truncation
      read_pointer_inc[i] <= '0; 
    end
  end
  else begin
    for (int i = 0; i < PORTS; i++) begin
      if(data_we_i) begin
        if(read_pointer[i] == ORDER - 1) read_pointer[i] <= '0;
        else read_pointer[i] <= read_pointer[i] + 1'b1;
        read_pointer_inc[i] <= read_pointer[i];
      end
      else if(data_rd_i) begin
        if(read_pointer_inc[i] == 0) read_pointer_inc[i] <= read_pointer_t'(ORDER - 1);   // Casting to avoid truncation warting 
        else read_pointer_inc[i] <= read_pointer_inc[i] - 1'b1;
      end
      else begin
        read_pointer_inc[i] <= read_pointer_inc[i];
      end
    end
  end
end

endmodule // fir_ram_data_ram
