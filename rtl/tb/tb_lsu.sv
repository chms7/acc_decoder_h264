
`timescale 1ns/10ps

`include "../core_defines.vh"       
// `define TEST_CYCLES_NUM 20000

parameter PERIOD = 680;

module tb_lsu;
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
    
    logic                        acc_cmd_valid_i;
    logic [acc_data_width-1:0]   acc_cmd_rs1_i;
    logic [acc_data_width-1:0]   acc_cmd_rs2_i;
    logic [acc_inst_width-1:0]   acc_cmd_inst_i;
    logic                        acc_cmd_ready_o;

    logic                        acc_resp_valid_o;
    logic [acc_data_width-1:0]   acc_resp_data_o;
    logic                        acc_resp_err_o;
    logic                        acc_resp_ready_i;

    logic                        acc_buffer_mem_req_ready_i;
    logic                        acc_buffer_mem_req_valid_o;
    logic [acc_addr_width-1:0]   acc_buffer_mem_req_addr_o;
    logic [acc_addr_width/8-1:0] acc_buffer_mem_req_wmask_o;
    logic [63:0]                 acc_buffer_mem_req_data_o;
    logic                        acc_buffer_mem_req_cmd_o;

    logic                        acc_buffer_mem_resp_valid_i;
    logic [63:0]                 acc_buffer_mem_resp_data_i;
    logic                        acc_buffer_mem_resp_err_i;

    logic                        acc_ram0_mem_req_ready_i;
    logic                        acc_ram0_mem_req_valid_o;
    logic [acc_addr_width-1:0]   acc_ram0_mem_req_addr_o;
    logic [7:0]                  acc_ram0_mem_req_wmask_o;
    logic [63:0]                 acc_ram0_mem_req_data_o;
    logic                        acc_ram0_mem_req_cmd_o;

    logic                        acc_ram0_mem_resp_valid_i;
    logic [63:0]                 acc_ram0_mem_resp_data_i;
    logic                        acc_ram0_mem_resp_err_i;

    logic                        acc_ram1_mem_req_ready_i;
    logic                        acc_ram1_mem_req_valid_o;
    logic [acc_addr_width-1:0]   acc_ram1_mem_req_addr_o;
    logic [7:0]                  acc_ram1_mem_req_wmask_o;
    logic [63:0]                 acc_ram1_mem_req_data_o;
    logic                        acc_ram1_mem_req_cmd_o;

    logic                        acc_ram1_mem_resp_valid_i;
    logic [63:0]                 acc_ram1_mem_resp_data_i;
    logic                        acc_ram1_mem_resp_err_i;
    
    
    logic decoder_start;
    
    decoder_top #(
        .dmem_data_width        ( 64              ),
        .acc_inst_width         ( `CORE_INSTWIDTH ),
        .acc_data_width         ( `CORE_DATAWIDTH ),
        .acc_addr_width         ( `CORE_ADDRWIDTH ),
        .acc_regfile_addr_width ( 2               )
    ) u_decoder_top (
        .clk_i                   ( clk                    ),
        .rst_ni                  ( rstn                   ),
        
        .decoder_start           ( decoder_start          ),

        .acc_cmd_valid_i         ( acc_cmd_valid_i        ),
        .acc_cmd_rs1_i           ( acc_cmd_rs1_i          ),
        .acc_cmd_rs2_i           ( acc_cmd_rs2_i          ),
        .acc_cmd_inst_i          ( acc_cmd_inst_i         ),
        .acc_cmd_ready_o         ( acc_cmd_ready_o        ),
    
        .acc_resp_valid_o        ( acc_resp_valid_o       ),
        .acc_resp_data_o         ( acc_resp_data_o        ),
        .acc_resp_err_o          ( acc_resp_err_o         ),
        .acc_resp_ready_i        ( acc_resp_ready_i       ),

        .acc_buffer_mem_req_valid_o   ( acc_buffer_mem_req_valid_o  ),
        .acc_buffer_mem_req_addr_o    ( acc_buffer_mem_req_addr_o   ),
        .acc_buffer_mem_req_wmask_o   ( acc_buffer_mem_req_wmask_o  ),
        .acc_buffer_mem_req_data_o    ( acc_buffer_mem_req_data_o   ),
        .acc_buffer_mem_req_cmd_o     ( acc_buffer_mem_req_cmd_o    ),
        .acc_buffer_mem_req_ready_i   ( acc_buffer_mem_req_ready_i  ),

        .acc_buffer_mem_resp_valid_i  ( acc_buffer_mem_resp_valid_i ),
        .acc_buffer_mem_resp_data_i   ( acc_buffer_mem_resp_data_i  ),
        .acc_buffer_mem_resp_err_i    ( acc_buffer_mem_resp_err_i   ),

        .acc_ram0_mem_req_valid_o     ( acc_ram0_mem_req_valid_o    ),
        .acc_ram0_mem_req_addr_o      ( acc_ram0_mem_req_addr_o     ),
        .acc_ram0_mem_req_wmask_o     ( acc_ram0_mem_req_wmask_o    ),
        .acc_ram0_mem_req_data_o      ( acc_ram0_mem_req_data_o     ),
        .acc_ram0_mem_req_cmd_o       ( acc_ram0_mem_req_cmd_o      ),
        .acc_ram0_mem_req_ready_i     ( acc_ram0_mem_req_ready_i    ),

        .acc_ram0_mem_resp_valid_i    ( acc_ram0_mem_resp_valid_i   ),
        .acc_ram0_mem_resp_data_i     ( acc_ram0_mem_resp_data_i    ),
        .acc_ram0_mem_resp_err_i      ( acc_ram0_mem_resp_err_i     ),

        .acc_ram1_mem_req_valid_o     ( acc_ram1_mem_req_valid_o    ),
        .acc_ram1_mem_req_addr_o      ( acc_ram1_mem_req_addr_o     ),
        .acc_ram1_mem_req_wmask_o     ( acc_ram1_mem_req_wmask_o    ),
        .acc_ram1_mem_req_data_o      ( acc_ram1_mem_req_data_o     ),
        .acc_ram1_mem_req_cmd_o       ( acc_ram1_mem_req_cmd_o      ),
        .acc_ram1_mem_req_ready_i     ( acc_ram1_mem_req_ready_i    ),

        .acc_ram1_mem_resp_valid_i    ( acc_ram1_mem_resp_valid_i   ),
        .acc_ram1_mem_resp_data_i     ( acc_ram1_mem_resp_data_i    ),
        .acc_ram1_mem_resp_err_i      ( acc_ram1_mem_resp_err_i     )
    );

    // interconnect master signals
    wire    [3:0]                        dmem_req_m      ;      
    wire    [3:0][14:0]                  dmem_addr_m     ;      
    wire    [3:0]                        dmem_wen_m      ;      
    wire    [3:0][63:0]                  dmem_wdata_m    ;      
    wire    [3:0][7:0]                   dmem_mask_m     ;      
    wire    [3:0]                        dmem_gnt_m      ;      
    wire    [3:0]                        dmem_vld_m      ;      
    wire    [3:0][63:0]                  dmem_rdata_m    ;         

    // interconnect slave signals
    wire   [3:0]                        dmem_req_s      ; 
    wire   [3:0]                        dmem_gnt_s      ; 
    wire   [3:0][12:0]                   dmem_addr_s     ;
    wire   [3:0]                        dmem_wen_s      ;
    wire   [3:0][63:0]                  dmem_wdata_s    ;
    wire   [3:0][7:0]                   dmem_mask_s     ; 
    wire   [3:0][63:0]                  dmem_rdata_s    ;

    /*
    wire                mem_lsu_gnt_i                   ;
    wire                mem_lsu_rsp_i                   ;
    wire    [31:0]      mem_lsu_rdata_i                 ;
    wire                lsu_mem_req_o                   ;
    wire    [31:0]      lsu_mem_addr_o                  ;
    wire                lsu_mem_wen_o                   ;
    wire    [31:0]      lsu_mem_wdata_o                 ;
    wire    [3:0]       lsu_mem_wmask_o                 ;
     */

    reg     [11:0]                      dmem_addr_r     ;
    wire                                lsu_mem_hsk_w    ;

    // assign lsu_mem_hsk_w = lsu_mem_req_o & mem_lsu_gnt_i;
    
    // always @ (posedge clk) begin
    //     if (lsu_mem_hsk_w) begin
    //         dmem_addr_r <= lsu_mem_addr_o[11:0];
    //     end
    // end



    // assign dmem_req_m       = {1'b0, 1'b0, 1'b0,  acc_buffer_mem_req_valid_o};
    // assign dmem_addr_m      = {15'd0,15'd0, 15'd0,  acc_buffer_mem_req_addr_o[14:2], 2'b00} ;  // here, we use the 11:1 part slice of the address, to divide 64bit rdata_o into 32bit rdata_i
    // assign dmem_wen_m       = {1'b0, 1'b0, 1'b0,  1'b0} ;
    // assign dmem_wdata_m     = {64'd0,64'd0, 64'd0,  64'd0} ;
    // assign dmem_mask_m      = {8'd0, 8'd0, 8'd0,  8'd0} ;

    assign dmem_req_m       = {1'b0,  acc_ram1_mem_req_valid_o,       acc_ram0_mem_req_valid_o,      acc_buffer_mem_req_valid_o     };
    assign dmem_addr_m      = {15'd0, acc_ram1_mem_req_addr_o[14:0],  acc_ram0_mem_req_addr_o[14:0], acc_buffer_mem_req_addr_o[14:0]};  // here, we use the 11:1 part slice of the address, to divide 64bit rdata_o into 32bit rdata_i
    assign dmem_wen_m       = {1'b0, ~acc_ram1_mem_req_cmd_o,        ~acc_ram0_mem_req_cmd_o,        1'b0                           };
    assign dmem_wdata_m     = {64'd0, acc_ram1_mem_req_data_o,        acc_ram0_mem_req_data_o,       64'd0                          };
    assign dmem_mask_m      = {8'd0,  acc_ram1_mem_req_wmask_o,       acc_ram0_mem_req_wmask_o,      8'd0                           };
    
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

    assign acc_buffer_mem_req_ready_i   = dmem_gnt_m[0];
    assign acc_buffer_mem_resp_valid_i  = dmem_vld_m[0];
    assign acc_buffer_mem_resp_data_i   = dmem_rdata_m[0];
    assign acc_ram0_mem_req_ready_i     = dmem_gnt_m[1];
    assign acc_ram0_mem_resp_valid_i    = dmem_vld_m[1];
    assign acc_ram0_mem_resp_data_i     = dmem_rdata_m[1];
    assign acc_ram1_mem_req_ready_i     = dmem_gnt_m[2];
    assign acc_ram1_mem_resp_valid_i    = dmem_vld_m[2];
    assign acc_ram1_mem_resp_data_i     = dmem_rdata_m[2];

    

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
    // initialize tb signals
	// test_cycles <= 0;
	rstn <= 1;
	clk <= 0;
 
    // initialize input signals
    // lsu_cmd_valid_i                 <= 1'b0     ;
    // lsu_cmd_i                       <= 3'd0     ;
    // lsu_cmd_target_i                <= 3'd0     ;
    // lsu_cmd_addr_i                  <= 32'd0    ;
    // lsu_cmd_stride_i                <= 32'd0    ;
    // lsu_cmd_len_i                   <= 4'd0     ;
    // lsu_conv_output_fifo_data_i     <= 8'd0     ;
    // lsu_conv_output_fifo_empty_i    <= 1'b0     ;

    $readmemh("test/frame/frame_0.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_0.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_0.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_0.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
    
    // reset
	#PERIOD rstn <= 1'b0;
	#PERIOD	rstn <= 1'b1;

  decoder_start <= 1'b1;

  wait(u_decoder_top.bitstream_ram_addr == 32'h000004b4);
  decoder_start <= 1'b0;

  #(PERIOD*50000)
    $readmemh("test/frame/frame_4.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_4.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_4.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_4.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #PERIOD
  decoder_start <= 1'b1;

  wait(u_decoder_top.bitstream_ram_addr == 32'h00000013);
  decoder_start <= 1'b0;

  #(PERIOD*50000)
    $readmemh("test/frame/frame_5.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_5.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_5.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_5.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #PERIOD
  decoder_start <= 1'b1;

  wait(u_decoder_top.bitstream_ram_addr == 32'h0000000d);
  decoder_start <= 1'b0;

  #(PERIOD*50000)
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #PERIOD
  decoder_start <= 1'b1;

  wait(u_decoder_top.bitstream_ram_addr == 32'h0000000d);
  decoder_start <= 1'b0;

  #(PERIOD*50000)
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #PERIOD
  decoder_start <= 1'b1;

  wait(u_decoder_top.bitstream_ram_addr == 32'h0000001a);
  decoder_start <= 1'b0;

  #(PERIOD*50000)
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #(PERIOD*10)
  decoder_start <= 1'b1;

  wait(u_decoder_top.bitstream_ram_addr == 32'h00000048);
  decoder_start <= 1'b0;

    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #(PERIOD*10)
  decoder_start <= 1'b1;

  wait(u_decoder_top.bitstream_ram_addr == 32'h00000074);
  decoder_start <= 1'b0;

    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_6.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #(PERIOD*10)
  decoder_start <= 1'b1;

  // #(PERIOD*100000)
  wait(u_decoder_top.bitstream_ram_addr == 32'h0000000d);
  decoder_start <= 1'b0;

    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_7.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #(PERIOD*10)
  decoder_start <= 1'b1;

  // #(PERIOD*100000)
  wait(u_decoder_top.bitstream_ram_addr == 32'h00000020);
  decoder_start <= 1'b0;

    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_8.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #(PERIOD*10)
  decoder_start <= 1'b1;

  // #(PERIOD*100000)
  wait(u_decoder_top.bitstream_ram_addr == 32'h00000027);
  decoder_start <= 1'b0;

    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_9.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #(PERIOD*10)
  decoder_start <= 1'b1;

  // #(PERIOD*100000)
  wait(u_decoder_top.bitstream_ram_addr == 32'h00000038);
  decoder_start <= 1'b0;

    $readmemh("test/frame/frame_10.txt", tb_acc.mem_banks.banks[0].bank_i.ram);
    $readmemh("test/frame/frame_10.txt", tb_acc.mem_banks.banks[1].bank_i.ram);
    $readmemh("test/frame/frame_10.txt", tb_acc.mem_banks.banks[2].bank_i.ram);
    $readmemh("test/frame/frame_10.txt", tb_acc.mem_banks.banks[3].bank_i.ram);
  #(PERIOD*10)
  decoder_start <= 1'b1;

  #(PERIOD*100000)
  decoder_start <= 1'b0;

  #(PERIOD*50000)

  $finish;

    // // test weight buffer
    // lsu_cmd_i                       <= 3'b000   ;    // single load cmd
    // lsu_cmd_valid_i                 <= 1'b1     ;
    // lsu_cmd_addr_i                  <= 32'd0    ;

    // #PERIOD
    // lsu_cmd_valid_i                 <= 1'b0     ;

    // #(4*PERIOD)
    // lsu_cmd_valid_i                 <= 1'b1     ;
    // lsu_cmd_addr_i                  <= 32'd1    ;    
    // #`PERIOD
    // lsu_cmd_valid_i                 <= 1'b0     ;

    // #(4*`PERIOD)
    // lsu_cmd_i                       <= 3'b010   ;   // burst load cmd
    // lsu_cmd_target_i                <= 3'b001   ;   // weight
    // lsu_cmd_valid_i                 <= 1'b1     ;
    // lsu_cmd_addr_i                  <= 32'd0    ;
    // lsu_cmd_stride_i                <= 32'd1    ;
    // lsu_cmd_len_i                   <= 4'd7     ;    
    
    // #`PERIOD
    // lsu_cmd_i                       <= 3'b000   ;
    // lsu_cmd_valid_i                 <= 1'b0     ;
    // lsu_cmd_target_i                <= 3'b000   ;

    // #(15*`PERIOD)
    // lsu_cmd_i                       <= 3'b010   ;   // burst load cmd
    // lsu_cmd_target_i                <= 3'b010   ;   // ifmap
    // lsu_cmd_valid_i                 <= 1'b1     ;
    // lsu_cmd_addr_i                  <= 32'd0    ;
    // lsu_cmd_stride_i                <= 32'd3    ;
    // lsu_cmd_len_i                   <= 4'd5     ;    
    
    // #`PERIOD
    // lsu_cmd_i                       <= 3'b000   ;
    // lsu_cmd_valid_i                 <= 1'b0     ;
    // lsu_cmd_target_i                <= 3'b000   ;   
end

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