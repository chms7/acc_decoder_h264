`include "core_defines.vh"       

module decoder_top
    //import manycore_pkg::*
#(
    parameter   dmem_data_width         = 64,
    parameter   acc_inst_width          = `CORE_INSTWIDTH,
    parameter   acc_data_width          = `CORE_DATAWIDTH,
    parameter   acc_addr_width          = `CORE_ADDRWIDTH,
    parameter   acc_regfile_addr_width  = 2
)(
    input  logic                         clk_i                        ,
    input  logic                         rst_ni                       ,
    
    // ---------------------------------------------------------------------------
    // Rocc Command Request Interface
    // ---------------------------------------------------------------------------
    input  logic                         acc_cmd_req_valid_i          ,
    input  logic [acc_data_width-1:0]    acc_cmd_req_rs1_i            ,
    input  logic [acc_data_width-1:0]    acc_cmd_req_rs2_i            ,
    input  logic [acc_inst_width-1:0]    acc_cmd_req_inst_i           ,
    output logic                         acc_cmd_req_ready_o          ,

    // ---------------------------------------------------------------------------
    // Rocc Command Response Interface
    // ---------------------------------------------------------------------------
    output logic                         acc_cmd_rsp_valid_o          ,
    output logic [acc_data_width-1:0]    acc_cmd_rsp_data_o           ,
    input  logic                         acc_cmd_rsp_ready_i          ,
    output logic                         acc_cmd_rsp_err_o            , 

    // ---------------------------------------------------------------------------
    // LSU Buffer Interface
    // ---------------------------------------------------------------------------
    output logic                         acc_lsu_buffer_req_valid_o   ,
    output logic [acc_addr_width-1:0]    acc_lsu_buffer_req_addr_o    ,
    output logic [acc_addr_width/8-1:0]  acc_lsu_buffer_req_wmask_o   ,
    output logic [63:0]                  acc_lsu_buffer_req_data_o    ,
    input  logic                         acc_lsu_buffer_req_ready_i   ,
    output logic                         acc_lsu_buffer_req_cmd_o     ,

    input  logic                         acc_lsu_buffer_rsp_valid_i   ,  
    input  logic [63:0]                  acc_lsu_buffer_rsp_data_i    ,
    input  logic                         acc_lsu_buffer_rsp_err_i     ,

    // ---------------------------------------------------------------------------
    // LSU RAM0 Interface
    // ---------------------------------------------------------------------------
    output logic                         acc_lsu_ram0_req_valid_o     ,
    output logic [acc_addr_width-1:0]    acc_lsu_ram0_req_addr_o      ,
    output logic [7:0]                   acc_lsu_ram0_req_wmask_o     ,
    output logic [63:0]                  acc_lsu_ram0_req_data_o      ,
    input  logic                         acc_lsu_ram0_req_ready_i     ,
    output logic                         acc_lsu_ram0_req_cmd_o       ,

    input  logic                         acc_lsu_ram0_rsp_valid_i     ,  
    input  logic [63:0]                  acc_lsu_ram0_rsp_data_i      ,
    input  logic                         acc_lsu_ram0_rsp_err_i       ,

    // ---------------------------------------------------------------------------
    // LSU RAM1 Interface
    // ---------------------------------------------------------------------------
    output logic                         acc_lsu_ram1_req_valid_o     ,
    output logic [acc_addr_width-1:0]    acc_lsu_ram1_req_addr_o      ,
    output logic [7:0]                   acc_lsu_ram1_req_wmask_o     ,
    output logic [63:0]                  acc_lsu_ram1_req_data_o      ,
    input  logic                         acc_lsu_ram1_req_ready_i     ,
    output logic                         acc_lsu_ram1_req_cmd_o       ,

    input  logic                         acc_lsu_ram1_rsp_valid_i     ,  
    input  logic [63:0]                  acc_lsu_ram1_rsp_data_i      ,
    input  logic                         acc_lsu_ram1_rsp_err_i
);
    // ---------------------------------------------------------------------------
    // Config Regfile
    // ---------------------------------------------------------------------------
    logic                              rf_wr_w;
    logic [acc_regfile_addr_width-1:0] rf_wr_idx_w;
    logic [acc_data_width-1:0]         rf_wr_data_w;

    logic [acc_data_width-1:0]         rf_rd_x0_buffer_req_base_w;
    logic [acc_data_width-1:0]         rf_rd_x1_buffer_req_end_w;
    logic [acc_data_width-1:0]         rf_rd_x2_ram0_req_base_w;
    logic [acc_data_width-1:0]         rf_rd_x3_ram1_req_base_w;

    decoder_regfile #(
        .dmem_data_width            ( dmem_data_width            ),
        .acc_inst_width             ( `CORE_INSTWIDTH            ),
        .acc_data_width             ( `CORE_DATAWIDTH            ),
        .acc_addr_width             ( `CORE_ADDRWIDTH            ),
        .acc_regfile_addr_width     ( acc_regfile_addr_width     )
    ) u_decoder_regfile (
        .clk_i                      ( clk_i                      ),
        .rst_ni                     ( rst_ni                     ),

        .rf_wr_i                    ( rf_wr_w                    ),
        .rf_wr_idx_i                ( rf_wr_idx_w                ),
        .rf_wr_data_i               ( rf_wr_data_w               ),

        .rf_rd_x0_buffer_req_base_o ( rf_rd_x0_buffer_req_base_w ),
        .rf_rd_x1_buffer_req_end_o  ( rf_rd_x1_buffer_req_end_w  ),
        .rf_rd_x2_ram0_req_base_o   ( rf_rd_x2_ram0_req_base_w   ),
        .rf_rd_x3_ram1_req_base_o   ( rf_rd_x3_ram1_req_base_w   )
    );

    // ---------------------------------------------------------------------------
    // Instruction Interface
    // ---------------------------------------------------------------------------
    logic buffer_req_start_w;
    logic decode_end_w;

    decoder_inst_interface #(
        .dmem_data_width        ( 64              ),
        .acc_inst_width         ( `CORE_INSTWIDTH ),
        .acc_data_width         ( `CORE_DATAWIDTH ),
        .acc_addr_width         ( `CORE_ADDRWIDTH ),
        .acc_regfile_addr_width ( 2               )
    ) u_decoder_inst_interface (
        .clk_i                       ( clk_i                        ),
        .rst_ni                      ( rst_ni                       ),

        .acc_cmd_req_valid_i         ( acc_cmd_req_valid_i          ),
        .acc_cmd_req_rs1_i           ( acc_cmd_req_rs1_i            ),
        .acc_cmd_req_rs2_i           ( acc_cmd_req_rs2_i            ),
        .acc_cmd_req_inst_i          ( acc_cmd_req_inst_i           ),
        .acc_cmd_rsp_ready_i         ( acc_cmd_rsp_ready_i          ),
        .acc_cmd_req_ready_o         ( acc_cmd_req_ready_o          ),
        .acc_cmd_rsp_valid_o         ( acc_cmd_rsp_valid_o          ),
        .acc_cmd_rsp_data_o          ( acc_cmd_rsp_data_o           ),
        .acc_cmd_rsp_err_o           ( acc_cmd_rsp_err_o            ),

        .rf_wr_o                     ( rf_wr_w                      ),
        .rf_wr_idx_o                 ( rf_wr_idx_w                  ),
        .rf_wr_data_o                ( rf_wr_data_w                 ),
        .rf_rd_x0_buffer_req_base_i  ( rf_rd_x0_buffer_req_base_w   ),
        .rf_rd_x1_buffer_req_end_i   ( rf_rd_x1_buffer_req_end_w    ),
        .rf_rd_x2_ram0_req_base_i    ( rf_rd_x2_ram0_req_base_w     ),
        .rf_rd_x3_ram1_req_base_i    ( rf_rd_x3_ram1_req_base_w     ),

        .acc_lsu_buffer_req_addr_i   ( acc_lsu_buffer_req_addr_o    ),
        .buffer_req_start_o          ( buffer_req_start_w           ),
        .decode_end_i                ( decode_end_w                 )
    );

    // ---------------------------------------------------------------------------
    // Decoder
    // ---------------------------------------------------------------------------
	logic        bitstream_ram_ren_n;
	logic [16:0] bitstream_ram_addr, bitstream_ram_addr_r;
	logic [15:0] bitstream_buffer_input;

    logic        ext_frame_RAM0_cs_n;
    logic        ext_frame_RAM0_wr;
	logic [13:0] ext_frame_RAM0_addr;
	logic [31:0] ext_frame_RAM0_data;
    
    logic        ext_frame_RAM1_cs_n;
    logic        ext_frame_RAM1_wr;
	logic [13:0] ext_frame_RAM1_addr;
	logic [31:0] ext_frame_RAM1_data;

	logic [31:0] dis_frame_RAM_din;

	logic [5:0]  pic_num;
	logic        slice_header_s6;
    
	nova u_decoder (
		.clk						( clk_i                  ),
		.reset_n					( rst_ni                 ),

		.mem_req_start				( buffer_req_start_w     ),
        .end_of_one_frame           ( decode_end_w           ),

		.BitStream_buffer_input	    ( bitstream_buffer_input ),
		.BitStream_ram_ren			( bitstream_ram_ren_n    ),
		.BitStream_ram_addr			( bitstream_ram_addr     ),

		.ext_frame_RAM0_cs_n		( ext_frame_RAM0_cs_n    ),
		.ext_frame_RAM0_wr			( ext_frame_RAM0_wr      ),
		.ext_frame_RAM0_addr		( ext_frame_RAM0_addr    ),
		.ext_frame_RAM0_data		( ext_frame_RAM0_data    ),
                                                             
		.ext_frame_RAM1_cs_n		( ext_frame_RAM1_cs_n    ),
		.ext_frame_RAM1_wr			( ext_frame_RAM1_wr      ),
		.ext_frame_RAM1_addr		( ext_frame_RAM1_addr    ),
		.ext_frame_RAM1_data		( ext_frame_RAM1_data    ), 

		.dis_frame_RAM_din			( dis_frame_RAM_din      ),

		.freq_ctrl0					( 1'b0                   ),
		.freq_ctrl1					( 1'b1                   ),
		.pin_disable_DF				( 1'b0                   ),
		.pic_num					( pic_num                ),
		.slice_header_s6			( slice_header_s6        )
    );
    
    // ---------------------------------------------------------------------------
    // LSU
    // ---------------------------------------------------------------------------
    decoder_lsu #(
        .dmem_data_width        ( 64              ),
        .acc_inst_width         ( `CORE_INSTWIDTH ),
        .acc_data_width         ( `CORE_DATAWIDTH ),
        .acc_addr_width         ( `CORE_ADDRWIDTH )
    ) u_decoder_lsu (
        .clk_i                   ( clk_i                       ),
        .rst_ni                  ( rst_ni                      ),

        .buffer_req_start_i      ( buffer_req_start_w          ),
        .bitstream_ram_ren_n     ( bitstream_ram_ren_n         ),
        .bitstream_ram_addr      ( bitstream_ram_addr          ),
        .bitstream_buffer_input  ( bitstream_buffer_input      ),
        .ext_frame_RAM0_cs_n     ( ext_frame_RAM0_cs_n         ),
        .ext_frame_RAM0_wr       ( ext_frame_RAM0_wr           ),
        .ext_frame_RAM0_addr     ( ext_frame_RAM0_addr         ),
        .ext_frame_RAM0_data     ( ext_frame_RAM0_data         ),
        .ext_frame_RAM1_cs_n     ( ext_frame_RAM1_cs_n         ),
        .ext_frame_RAM1_wr       ( ext_frame_RAM1_wr           ),
        .ext_frame_RAM1_addr     ( ext_frame_RAM1_addr         ),
        .ext_frame_RAM1_data     ( ext_frame_RAM1_data         ),
        .dis_frame_RAM_din       ( dis_frame_RAM_din           ),

        .buffer_mem_req_valid_o  ( acc_lsu_buffer_req_valid_o  ),
        .buffer_mem_req_addr_o   ( acc_lsu_buffer_req_addr_o   ),
        .buffer_mem_req_wmask_o  ( acc_lsu_buffer_req_wmask_o  ),
        .buffer_mem_req_data_o   ( acc_lsu_buffer_req_data_o   ),
        .buffer_mem_req_cmd_o    ( acc_lsu_buffer_req_cmd_o    ),
        .buffer_mem_req_ready_i  ( acc_lsu_buffer_req_ready_i  ),
        .buffer_mem_rsp_valid_i  ( acc_lsu_buffer_rsp_valid_i  ),
        .buffer_mem_rsp_data_i   ( acc_lsu_buffer_rsp_data_i   ),
        .buffer_mem_rsp_err_i    ( acc_lsu_buffer_rsp_err_i    ),

        .ram0_mem_req_valid_o    ( acc_lsu_ram0_req_valid_o    ),
        .ram0_mem_req_addr_o     ( acc_lsu_ram0_req_addr_o     ),
        .ram0_mem_req_wmask_o    ( acc_lsu_ram0_req_wmask_o    ),
        .ram0_mem_req_data_o     ( acc_lsu_ram0_req_data_o     ),
        .ram0_mem_req_cmd_o      ( acc_lsu_ram0_req_cmd_o      ),
        .ram0_mem_req_ready_i    ( acc_lsu_ram0_req_ready_i    ),
        .ram0_mem_rsp_valid_i    ( acc_lsu_ram0_rsp_valid_i    ),
        .ram0_mem_rsp_data_i     ( acc_lsu_ram0_rsp_data_i     ),
        .ram0_mem_rsp_err_i      ( acc_lsu_ram0_rsp_err_i      ),

        .ram1_mem_req_valid_o    ( acc_lsu_ram1_req_valid_o    ),
        .ram1_mem_req_addr_o     ( acc_lsu_ram1_req_addr_o     ),
        .ram1_mem_req_wmask_o    ( acc_lsu_ram1_req_wmask_o    ),
        .ram1_mem_req_data_o     ( acc_lsu_ram1_req_data_o     ),
        .ram1_mem_req_cmd_o      ( acc_lsu_ram1_req_cmd_o      ),
        .ram1_mem_req_ready_i    ( acc_lsu_ram1_req_ready_i    ),
        .ram1_mem_rsp_valid_i    ( acc_lsu_ram1_rsp_valid_i    ),
        .ram1_mem_rsp_data_i     ( acc_lsu_ram1_rsp_data_i     ),
        .ram1_mem_rsp_err_i      ( acc_lsu_ram1_rsp_err_i      )
    );
    
    // ---------------------------------------------------------------------------
    // Record Result for Display
    // ---------------------------------------------------------------------------
	ext_frame_RAM0_wrapper ext_frame_RAM0_wrapper (
		.clk                    ( clk_i               ),
		.reset_n                ( rst_ni              ),
		.ext_frame_RAM0_cs_n    ( ext_frame_RAM0_cs_n ),
		.ext_frame_RAM0_wr      ( ext_frame_RAM0_wr   ),
		.ext_frame_RAM0_addr    ( ext_frame_RAM0_addr ),
		.dis_frame_RAM_din      ( dis_frame_RAM_din   ),
		// .ext_frame_RAM0_data    ( ext_frame_RAM0_data ),
		.pic_num                ( pic_num             ),
		.slice_header_s6        ( slice_header_s6     )
	);

	ext_frame_RAM1_wrapper ext_frame_RAM1_wrapper (
		.clk                    ( clk_i               ),
		.reset_n                ( rst_ni              ),
		.ext_frame_RAM1_cs_n    ( ext_frame_RAM1_cs_n ),
		.ext_frame_RAM1_wr      ( ext_frame_RAM1_wr   ),
		.ext_frame_RAM1_addr    ( ext_frame_RAM1_addr ),
		.dis_frame_RAM_din      ( dis_frame_RAM_din   ),
		// .ext_frame_RAM1_data    ( ext_frame_RAM1_data ),
		.pic_num                ( pic_num             ),
		.slice_header_s6        ( slice_header_s6     )
	);

    
endmodule