// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on
module memcic_ram (
	clock,
	data,
	rdaddress,
	wraddress,
	wren,
	q);
  
  parameter DWIDTH = 72;
  parameter AWIDTH = 5;
  localparam WORDS = 1 << AWIDTH;
  
	input	                  clock;
	input	[DWIDTH - 1:0]    data;
	input	[AWIDTH - 1:0]    rdaddress;
	input	[AWIDTH - 1:0]    wraddress;
	input	                  wren;
	output	[DWIDTH - 1:0]  q;

	wire [DWIDTH - 1:0] sub_wire0;
	wire [DWIDTH - 1:0] q = sub_wire0[DWIDTH - 1:0];

	altsyncram	altsyncram_component (
				.address_a (wraddress),
				.clock0 (clock),
				.data_a (data),
				.wren_a (wren),
				.address_b (rdaddress),
				.q_b (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b ({72{1'b1}}),
				.eccstatus (),
				.q_a (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone IV E",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = WORDS,
		altsyncram_component.numwords_b = WORDS,
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = AWIDTH,
		altsyncram_component.widthad_b = AWIDTH,
		altsyncram_component.width_a = DWIDTH,
		altsyncram_component.width_b = DWIDTH,
		altsyncram_component.width_byteena_a = 1;


endmodule
