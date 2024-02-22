
`timescale 1ns/10ps

`include "../core_defines.vh"       
// `define TEST_CYCLES_NUM 20000

parameter PERIOD = 680;

module tb_acc;
    // int                 test_cycles = 0;

    //-----------------------------------------------
    // clock & reset
    //-----------------------------------------------
    reg                 clk;
    reg                 rstn;

	  always #(PERIOD/2) clk = ~clk;
    
    //-----------------------------------------------
    // decoder
    //-----------------------------------------------
    // defines
    parameter dmem_data_width         = 64             ;
    parameter acc_inst_width          = `CORE_INSTWIDTH;
    parameter acc_data_width          = `CORE_DATAWIDTH;
    parameter acc_addr_width          = `CORE_ADDRWIDTH;
    parameter acc_regfile_addr_width  = 2              ;

    localparam OPCODE_CUSTOM3       = 7'b11_110_11;

    localparam FUNCT7_WR_BUF_BASE   = 7'b000_1_00;
    localparam FUNCT7_WR_BUF_END    = 7'b000_1_01;
    localparam FUNCT7_WR_RAM0_BASE  = 7'b000_1_10;
    localparam FUNCT7_WR_RAM1_BASE  = 7'b000_1_11;

    localparam FUNCT7_RD_BUF_BASE   = 7'b000_0_00;
    localparam FUNCT7_RD_BUF_END    = 7'b000_0_01;
    localparam FUNCT7_RD_RAM0_BASE  = 7'b000_0_10;
    localparam FUNCT7_RD_RAM1_BASE  = 7'b000_0_11;

    localparam FUNCT7_START         = 7'b100_0_00;
    
    logic                        acc_cmd_req_valid_i;
    logic [acc_data_width-1:0]   acc_cmd_req_rs1_i;
    logic [acc_data_width-1:0]   acc_cmd_req_rs2_i;
    logic [acc_inst_width-1:0]   acc_cmd_req_inst_i;
    logic                        acc_cmd_req_ready_o;

    logic                        acc_cmd_rsp_valid_o;
    logic [acc_data_width-1:0]   acc_cmd_rsp_data_o;
    logic                        acc_cmd_rsp_err_o;
    logic                        acc_cmd_rsp_ready_i;

    logic                        acc_lsu_buffer_req_ready_i;
    logic                        acc_lsu_buffer_req_valid_o;
    logic [acc_addr_width-1:0]   acc_lsu_buffer_req_addr_o;
    logic [acc_addr_width/8-1:0] acc_lsu_buffer_req_wmask_o;
    logic [63:0]                 acc_lsu_buffer_req_data_o;
    logic                        acc_lsu_buffer_req_cmd_o;

    logic                        acc_lsu_buffer_rsp_valid_i;
    logic [63:0]                 acc_lsu_buffer_rsp_data_i;
    logic                        acc_lsu_buffer_rsp_err_i;

    logic                        acc_lsu_ram0_req_ready_i;
    logic                        acc_lsu_ram0_req_valid_o;
    logic [acc_addr_width-1:0]   acc_lsu_ram0_req_addr_o;
    logic [7:0]                  acc_lsu_ram0_req_wmask_o;
    logic [63:0]                 acc_lsu_ram0_req_data_o;
    logic                        acc_lsu_ram0_req_cmd_o;

    logic                        acc_lsu_ram0_rsp_valid_i;
    logic [63:0]                 acc_lsu_ram0_rsp_data_i;
    logic                        acc_lsu_ram0_rsp_err_i;

    logic                        acc_lsu_ram1_req_ready_i;
    logic                        acc_lsu_ram1_req_valid_o;
    logic [acc_addr_width-1:0]   acc_lsu_ram1_req_addr_o;
    logic [7:0]                  acc_lsu_ram1_req_wmask_o;
    logic [63:0]                 acc_lsu_ram1_req_data_o;
    logic                        acc_lsu_ram1_req_cmd_o;

    logic                        acc_lsu_ram1_rsp_valid_i;
    logic [63:0]                 acc_lsu_ram1_rsp_data_i;
    logic                        acc_lsu_ram1_rsp_err_i;
    
    decoder_top #(
        .dmem_data_width             ( 64                         ),
        .acc_inst_width              ( `CORE_INSTWIDTH            ),
        .acc_data_width              ( `CORE_DATAWIDTH            ),
        .acc_addr_width              ( `CORE_ADDRWIDTH            ),
        .acc_regfile_addr_width      ( 2                          )
    ) u_decoder_top (
        .clk_i                       ( clk                        ),
        .rst_ni                      ( rstn                       ),

        .acc_cmd_req_valid_i         ( acc_cmd_req_valid_i        ),
        .acc_cmd_req_rs1_i           ( acc_cmd_req_rs1_i          ),
        .acc_cmd_req_rs2_i           ( acc_cmd_req_rs2_i          ),
        .acc_cmd_req_inst_i          ( acc_cmd_req_inst_i         ),
        .acc_cmd_req_ready_o         ( acc_cmd_req_ready_o        ),
    
        .acc_cmd_rsp_valid_o         ( acc_cmd_rsp_valid_o        ),
        .acc_cmd_rsp_data_o          ( acc_cmd_rsp_data_o         ),
        .acc_cmd_rsp_err_o           ( acc_cmd_rsp_err_o          ),
        .acc_cmd_rsp_ready_i         ( acc_cmd_rsp_ready_i        ),

        .acc_lsu_buffer_req_valid_o  ( acc_lsu_buffer_req_valid_o ),
        .acc_lsu_buffer_req_addr_o   ( acc_lsu_buffer_req_addr_o  ),
        .acc_lsu_buffer_req_wmask_o  ( acc_lsu_buffer_req_wmask_o ),
        .acc_lsu_buffer_req_data_o   ( acc_lsu_buffer_req_data_o  ),
        .acc_lsu_buffer_req_cmd_o    ( acc_lsu_buffer_req_cmd_o   ),
        .acc_lsu_buffer_req_ready_i  ( acc_lsu_buffer_req_ready_i ),

        .acc_lsu_buffer_rsp_valid_i  ( acc_lsu_buffer_rsp_valid_i ),
        .acc_lsu_buffer_rsp_data_i   ( acc_lsu_buffer_rsp_data_i  ),
        .acc_lsu_buffer_rsp_err_i    ( acc_lsu_buffer_rsp_err_i   ),

        .acc_lsu_ram0_req_valid_o    ( acc_lsu_ram0_req_valid_o   ),
        .acc_lsu_ram0_req_addr_o     ( acc_lsu_ram0_req_addr_o    ),
        .acc_lsu_ram0_req_wmask_o    ( acc_lsu_ram0_req_wmask_o   ),
        .acc_lsu_ram0_req_data_o     ( acc_lsu_ram0_req_data_o    ),
        .acc_lsu_ram0_req_cmd_o      ( acc_lsu_ram0_req_cmd_o     ),
        .acc_lsu_ram0_req_ready_i    ( acc_lsu_ram0_req_ready_i   ),

        .acc_lsu_ram0_rsp_valid_i    ( acc_lsu_ram0_rsp_valid_i   ),
        .acc_lsu_ram0_rsp_data_i     ( acc_lsu_ram0_rsp_data_i    ),
        .acc_lsu_ram0_rsp_err_i      ( acc_lsu_ram0_rsp_err_i     ),

        .acc_lsu_ram1_req_valid_o    ( acc_lsu_ram1_req_valid_o   ),
        .acc_lsu_ram1_req_addr_o     ( acc_lsu_ram1_req_addr_o    ),
        .acc_lsu_ram1_req_wmask_o    ( acc_lsu_ram1_req_wmask_o   ),
        .acc_lsu_ram1_req_data_o     ( acc_lsu_ram1_req_data_o    ),
        .acc_lsu_ram1_req_cmd_o      ( acc_lsu_ram1_req_cmd_o     ),
        .acc_lsu_ram1_req_ready_i    ( acc_lsu_ram1_req_ready_i   ),

        .acc_lsu_ram1_rsp_valid_i    ( acc_lsu_ram1_rsp_valid_i   ),
        .acc_lsu_ram1_rsp_data_i     ( acc_lsu_ram1_rsp_data_i    ),
        .acc_lsu_ram1_rsp_err_i      ( acc_lsu_ram1_rsp_err_i     )
    );

    // interconnect master signals
    wire   [3:0]                        dmem_req_m      ;      
    wire   [3:0][14:0]                  dmem_addr_m     ;      
    wire   [3:0]                        dmem_wen_m      ;      
    wire   [3:0][63:0]                  dmem_wdata_m    ;      
    wire   [3:0][7:0]                   dmem_mask_m     ;      
    wire   [3:0]                        dmem_gnt_m      ;      
    wire   [3:0]                        dmem_vld_m      ;      
    wire   [3:0][63:0]                  dmem_rdata_m    ;         

    // interconnect slave signals
    wire   [3:0]                        dmem_req_s      ; 
    wire   [3:0]                        dmem_gnt_s      ; 
    wire   [3:0][12:0]                  dmem_addr_s     ;
    wire   [3:0]                        dmem_wen_s      ;
    wire   [3:0][63:0]                  dmem_wdata_s    ;
    wire   [3:0][7:0]                   dmem_mask_s     ; 
    wire   [3:0][63:0]                  dmem_rdata_s    ;

    // assign dmem_req_m       = {1'b0, 1'b0, 1'b0,  acc_buffer_mem_req_valid_o};
    // assign dmem_addr_m      = {15'd0,15'd0, 15'd0,  acc_buffer_mem_req_addr_o[14:2], 2'b00} ;  // here, we use the 11:1 part slice of the address, to divide 64bit rdata_o into 32bit rdata_i
    // assign dmem_wen_m       = {1'b0, 1'b0, 1'b0,  1'b0} ;
    // assign dmem_wdata_m     = {64'd0,64'd0, 64'd0,  64'd0} ;
    // assign dmem_mask_m      = {8'd0, 8'd0, 8'd0,  8'd0} ;

    assign dmem_req_m       = {1'b0,  acc_lsu_ram1_req_valid_o,       acc_lsu_ram0_req_valid_o,      acc_lsu_buffer_req_valid_o     };
    assign dmem_addr_m      = {15'd0, acc_lsu_ram1_req_addr_o[14:0],  acc_lsu_ram0_req_addr_o[14:0], acc_lsu_buffer_req_addr_o[14:0]};  // here, we use the 11:1 part slice of the address, to divide 64bit rdata_o into 32bit rdata_i
    assign dmem_wen_m       = {1'b0, ~acc_lsu_ram1_req_cmd_o,        ~acc_lsu_ram0_req_cmd_o,        1'b0                           };
    assign dmem_wdata_m     = {64'd0, acc_lsu_ram1_req_data_o,        acc_lsu_ram0_req_data_o,       64'd0                          };
    assign dmem_mask_m      = {8'd0,  acc_lsu_ram1_req_wmask_o,       acc_lsu_ram0_req_wmask_o,      8'd0                           };
    
    wire [14:0] dmem_addr_m_0 = dmem_addr_m[0];
    wire [14:0] dmem_addr_m_1 = dmem_addr_m[1];
    wire [14:0] dmem_addr_m_2 = dmem_addr_m[2];
    wire [14:0] dmem_addr_m_3 = dmem_addr_m[3];

    wire [12:0] dmem_addr_s_0 = dmem_addr_s[0];
    wire [12:0] dmem_addr_s_1 = dmem_addr_s[1];
    wire [12:0] dmem_addr_s_2 = dmem_addr_s[2];
    wire [12:0] dmem_addr_s_3 = dmem_addr_s[3];
    
    wire [63:0] dmem_rdata_m_0 = dmem_rdata_m[0];
    wire [63:0] dmem_rdata_m_1 = dmem_rdata_m[1];
    wire [63:0] dmem_rdata_m_2 = dmem_rdata_m[2];
    wire [63:0] dmem_rdata_m_3 = dmem_rdata_m[3];

    assign acc_lsu_buffer_req_ready_i  = dmem_gnt_m[0];
    assign acc_lsu_buffer_rsp_valid_i  = dmem_vld_m[0];
    assign acc_lsu_buffer_rsp_data_i   = dmem_rdata_m[0];
    assign acc_lsu_ram0_req_ready_i    = dmem_gnt_m[1];
    assign acc_lsu_ram0_rsp_valid_i    = dmem_vld_m[1];
    assign acc_lsu_ram0_rsp_data_i     = dmem_rdata_m[1];
    assign acc_lsu_ram1_req_ready_i    = dmem_gnt_m[2];
    assign acc_lsu_ram1_rsp_valid_i    = dmem_vld_m[2];
    assign acc_lsu_ram1_rsp_data_i     = dmem_rdata_m[2];

    

    tcdm_interconnect #(
    .NumIn                          ( 4                             ),
    .NumOut                         ( 4                             ),
    .AddrWidth                      ( 15                            ),
    .DataWidth                      ( 64                            ),
    .BeWidth                        ( 8                             ),
    .AddrMemWidth                   ( 13                            ),
    .WriteRespOn                    ( 1                             ),
    .RespLat                        ( 1                             ),
    .ByteOffWidth                   ( 0                             )
  ) dmem_interconnect (
    .clk_i                          ( clk           ),
    .rst_ni                         ( rstn          ),
    // master side
    .req_i                          ( dmem_req_m    ),
    .add_i                          ( dmem_addr_m   ),
    .wen_i                          ( dmem_wen_m    ),
    .wdata_i                        ( dmem_wdata_m  ),
    .be_i                           ( dmem_mask_m   ),
    .gnt_o                          ( dmem_gnt_m    ), 
    .vld_o                          ( dmem_vld_m    ),
    .rdata_o                        ( dmem_rdata_m  ),
    // slave side
    .req_o                          ( dmem_req_s    ),
    .gnt_i                          ( dmem_gnt_s    ),
    .add_o                          ( dmem_addr_s   ),
    .wen_o                          ( dmem_wen_s    ),
    .wdata_o                        ( dmem_wdata_s  ),
    .be_o                           ( dmem_mask_s   ),
    .rdata_i                        ( dmem_rdata_s  )
  );

    dtcm_banks #(
    .bank_size_p                    ( 65536         ),
    .bank_num_p                     ( 4             ),
    .bank_words_p                   ( 8192          ),
    .data_width_p                   ( 64            ),
    .addr_width_p                   ( 13            )
  ) mem_banks (
    .clk_i                          ( clk           ),
    .rst_ni                         ( rstn          ),

    .req_i                          ( dmem_req_s    ), 
    .gnt_o                          ( dmem_gnt_s    ), 
    .addr_i                         ( dmem_addr_s   ),
    .wen_i                          ( dmem_wen_s    ),
    .wdata_i                        ( dmem_wdata_s  ),
    .mask_i                         ( dmem_mask_s   ), 
    .rdata_o                        ( dmem_rdata_s  )
  );




initial begin
	// test_cycles <= 0;
	rstn <= 1;
	clk <= 0;
  
  acc_cmd_req_valid_i <= '0;
  acc_cmd_req_rs1_i   <= '0;
  acc_cmd_req_rs2_i   <= '0;
  acc_cmd_req_inst_i  <= '0;
    
  // reset
	#PERIOD rstn <= 1'b0;
	#PERIOD	rstn <= 1'b1;
 
  // frame 0
  @(posedge clk)
    $readmemh("test/frame/frame_0.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_0.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_0.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_0.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_04b4);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // frame 1
  @(posedge clk)
    $readmemh("test/frame/frame_4.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_4.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_4.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_4.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_0014);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // frame 2
  @(posedge clk)
    $readmemh("test/frame/frame_5.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_5.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_5.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_5.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_000c);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // frame 3
  @(posedge clk)
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_000c);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // frame 4
  @(posedge clk)
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_001c);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // frame 5
  @(posedge clk)
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_0028);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // frame 6
  @(posedge clk)
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_0038);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // // frame 7
  // @(posedge clk)
  //   $readmemh("test/frame/frame_10.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
  //   $readmemh("test/frame/frame_10.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
  //   $readmemh("test/frame/frame_10.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
  //   $readmemh("test/frame/frame_10.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  // acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_000c);
  // acc_start;

  // wait(acc_cmd_rsp_valid_o);
  //   acc_cmd_req_valid_i <= 1'b0;

  // frame 8
  @(posedge clk)
    $readmemh("test/frame/frame_11.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_11.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_11.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_11.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_0020);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // frame 9
  @(posedge clk)
    $readmemh("test/frame/frame_12.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_12.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_12.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_12.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_0024);
  acc_start;

  wait(acc_cmd_rsp_valid_o);
    acc_cmd_req_valid_i <= 1'b0;

  // // frame 10
  // @(posedge clk)
  //   $readmemh("test/frame/frame_13.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
  //   $readmemh("test/frame/frame_13.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
  //   $readmemh("test/frame/frame_13.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
  //   $readmemh("test/frame/frame_13.txt", tb_acc.mem_banks.banks[3].bank_i.ram);

  // acc_regfile_wr(FUNCT7_WR_BUF_END, 32'h0000_0038);
  // acc_start;

  // wait(acc_cmd_rsp_valid_o);
  //   acc_cmd_req_valid_i <= 1'b0;

  #(PERIOD*50000)

  $finish;

end

task acc_regfile_wr(
  input  logic [7:0]  funct7_i,
  input  logic [31:0] config_data_i
);
  @(posedge clk)
    acc_cmd_req_valid_i <= 1'b1;
    acc_cmd_req_inst_i  <= {funct7_i, 5'd0, 5'd0, 1'b0, 1'b1, 1'b0, 5'd0, OPCODE_CUSTOM3};
    acc_cmd_req_rs1_i   <= config_data_i;
endtask

task acc_start;
  @(posedge clk)
    acc_cmd_req_valid_i <= 1'b1;
    acc_cmd_req_inst_i  <= {FUNCT7_START, 5'd0, 5'd0, 1'b0, 1'b0, 1'b0, 5'd0, OPCODE_CUSTOM3};
endtask

// always begin
// 	// #(PERIOD/2) clk <= ~clk;
// 	test_cycles <= test_cycles + 1;
// 	if (test_cycles >= `TEST_CYCLES_NUM - 1) $finish;
// end

// initial begin
// 	$fsdbDumpfile("test.fsdb");
// 	$fsdbDumpvars(0);
//     $fsdbDumpMDA();
// end
	initial begin
	  $dumpfile("sim/wave.vcd");
	  $dumpvars(0, tb_acc);
	end


endmodule