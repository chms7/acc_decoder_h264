//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : nova_tb.v
// Generated : March 13,2006
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Testbench for nova
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
// `include "timescale.v"
// synopsys translate_on
`timescale 1ns/1ns
`include "nova_defines.v"

module tb_nova;
	
	reg clk;
	reg reset_n;
	reg mem_req_start;
	reg pin_disable_DF;
	reg freq_ctrl0;
	reg freq_ctrl1;
	
	wire BitStream_ram_ren;
	wire [16:0] BitStream_ram_addr; 
	wire [15:0] BitStream_buffer_input;
	wire [5:0] pic_num;
	wire [6:0] mb_num;
	
	wire [13:0] ext_frame_RAM0_addr;
	wire [31:0] ext_frame_RAM0_data;
	wire [13:0] ext_frame_RAM1_addr;
	wire [31:0] ext_frame_RAM1_data;
	wire [31:0] dis_frame_RAM_din;
	
	wire [15:0] temp;
	assign temp = dis_frame_RAM_din[15:0];
	
	//for debug only
	wire slice_header_s6;
	
	Beha_BitStream_ram Beha_BitStream_ram (
		.clk(clk),
		.BitStream_ram_ren(BitStream_ram_ren),
		.BitStream_ram_addr(BitStream_ram_addr),
		.BitStream_ram_data(BitStream_buffer_input)
		);
	ext_frame_RAM0_wrapper ext_frame_RAM0_wrapper (
		.clk(clk),
		.reset_n(reset_n),
		.ext_frame_RAM0_cs_n(ext_frame_RAM0_cs_n),
		.ext_frame_RAM0_wr(ext_frame_RAM0_wr),
		.ext_frame_RAM0_addr(ext_frame_RAM0_addr),
		.dis_frame_RAM_din(dis_frame_RAM_din),
		.ext_frame_RAM0_data(ext_frame_RAM0_data),
		.pic_num(pic_num),
		.slice_header_s6(slice_header_s6)
		);
	ext_frame_RAM1_wrapper ext_frame_RAM1_wrapper (
		.clk(clk),
		.reset_n(reset_n),
		.ext_frame_RAM1_cs_n(ext_frame_RAM1_cs_n),
		.ext_frame_RAM1_wr(ext_frame_RAM1_wr),
		.ext_frame_RAM1_addr(ext_frame_RAM1_addr),
		.dis_frame_RAM_din(dis_frame_RAM_din),
		.ext_frame_RAM1_data(ext_frame_RAM1_data),
		.pic_num(pic_num),
		.slice_header_s6(slice_header_s6)
		);
	wire [15:0] BitStream_buffer_input_1;
	assign BitStream_buffer_input_1 = mem_req_start ? BitStream_buffer_input : 16'b0;
	nova nova (
		.clk										(clk),
		.reset_n								(reset_n),

		.mem_req_start					(mem_req_start),
		.BitStream_buffer_input	(BitStream_buffer_input_1),
		.BitStream_ram_ren			(BitStream_ram_ren),
		.BitStream_ram_addr			(BitStream_ram_addr),

		.ext_frame_RAM0_cs_n		(ext_frame_RAM0_cs_n),
		.ext_frame_RAM0_wr			(ext_frame_RAM0_wr),
		.ext_frame_RAM0_addr		(ext_frame_RAM0_addr),
		.ext_frame_RAM0_data		(ext_frame_RAM0_data),

		.ext_frame_RAM1_cs_n		(ext_frame_RAM1_cs_n),
		.ext_frame_RAM1_wr			(ext_frame_RAM1_wr),
		.ext_frame_RAM1_addr		(ext_frame_RAM1_addr),
		.ext_frame_RAM1_data		(ext_frame_RAM1_data), 

		.dis_frame_RAM_din			(dis_frame_RAM_din),

		.freq_ctrl0							(freq_ctrl0),
		.freq_ctrl1							(freq_ctrl1),
		.pic_num								(pic_num),
		.pin_disable_DF					(pin_disable_DF),
		.slice_header_s6				(slice_header_s6)
  );
	
	localparam PERIOD = 680;
		
	initial
		begin
			// $readmemh("test/akiyo300_1ref.txt",Beha_BitStream_ram.BitStream_ram);
			clk = 1'b1;
			reset_n = 1'b1;
			mem_req_start = 1'b0;
			pin_disable_DF = 1'b0;
			freq_ctrl0 = 1'b0;
			freq_ctrl1 = 1'b1;
			#(PERIOD*3) reset_n = 1'b0;
			#(PERIOD*3) reset_n = 1'b1;
			
			#(PERIOD*10)
			$readmemh("test/frame_nova/frame_0.txt",Beha_BitStream_ram.BitStream_ram);
			mem_req_start = 1'b1;

			#(PERIOD*60000)
			mem_req_start = 1'b0;
			#(PERIOD)
			mem_req_start = 1'b1;
			$readmemh("test/frame_nova/frame_4.txt",Beha_BitStream_ram.BitStream_ram);

			#(PERIOD*60000)
			mem_req_start = 1'b0;
			#(PERIOD)
			mem_req_start = 1'b1;
			$readmemh("test/frame_nova/frame_5.txt",Beha_BitStream_ram.BitStream_ram);

			#(PERIOD*60000)
			mem_req_start = 1'b0;
			#(PERIOD)
			mem_req_start = 1'b1;
			$readmemh("test/frame_nova/frame_6.txt",Beha_BitStream_ram.BitStream_ram);

			#(PERIOD*60000)
			mem_req_start = 1'b0;
			#(PERIOD)
			mem_req_start = 1'b1;
			$readmemh("test/frame_nova/frame_7.txt",Beha_BitStream_ram.BitStream_ram);

			#(PERIOD*60000)
			mem_req_start = 1'b0;
			#(PERIOD)
			mem_req_start = 1'b1;
			$readmemh("test/frame_nova/frame_8.txt",Beha_BitStream_ram.BitStream_ram);

			#(PERIOD*60000)
			mem_req_start = 1'b0;
			// #(PERIOD)
			// mem_req_start = 1'b1;
			// $readmemh("test/frame_nova/frame_9.txt",Beha_BitStream_ram.BitStream_ram);

			// #(PERIOD*60000)
			// mem_req_start = 1'b0;
			// #(PERIOD)
			// mem_req_start = 1'b1;
			// $readmemh("test/frame_nova/frame_10.txt",Beha_BitStream_ram.BitStream_ram);

			// #(PERIOD*60000)
			// mem_req_start = 1'b0;
			// #(PERIOD)
			// mem_req_start = 1'b1;
			// $readmemh("test/frame_nova/frame_11.txt",Beha_BitStream_ram.BitStream_ram);

			// #(PERIOD*60000)
			// mem_req_start = 1'b0;
			// #(PERIOD)
			// mem_req_start = 1'b1;
			// $readmemh("test/frame_nova/frame_12.txt",Beha_BitStream_ram.BitStream_ram);

			// #(PERIOD*60000)
			// mem_req_start = 1'b0;
			// #(PERIOD)	// !
			// mem_req_start = 1'b1;
			// $readmemh("test/frame_nova/frame_13.txt",Beha_BitStream_ram.BitStream_ram);

			// #(PERIOD*60000)
			// mem_req_start = 1'b0;
			// #(PERIOD)
			// mem_req_start = 1'b1;
			// $readmemh("test/frame_nova/frame_14.txt",Beha_BitStream_ram.BitStream_ram);

			// #(PERIOD*60000)
			// mem_req_start = 1'b0;
			// #(PERIOD)
			// mem_req_start = 1'b1;
			// $readmemh("test/frame_nova/frame_15.txt",Beha_BitStream_ram.BitStream_ram);

			#200000000
			// #4000000000
			// #4000000000
			// #4000000000
			$finish;
		end

	always 
		#(PERIOD/2) clk = ~clk;
	
	// Dump Wave
	initial begin
	  $dumpfile("sim/wave.vcd");
	  $dumpvars(0, tb_nova);
	end

endmodule
