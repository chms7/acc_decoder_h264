`include "core_defines.vh"       

module decoder_lsu #(
  parameter   dmem_data_width         = 64,
  parameter   acc_inst_width          = `CORE_INSTWIDTH,
  parameter   acc_data_width          = `CORE_DATAWIDTH,
  parameter   acc_addr_width          = `CORE_ADDRWIDTH
)(
  input  logic                         clk_i                  ,
  input  logic                         rst_ni                 ,
  
	input  logic                         buffer_req_start_i     ,

	input  logic                         bitstream_ram_ren_n    ,
	input  logic [16:0]                  bitstream_ram_addr     ,
	output logic [15:0]                  bitstream_buffer_input ,

  input  logic                         ext_frame_RAM0_cs_n    ,
  input  logic                         ext_frame_RAM0_wr      ,
	input  logic [13:0]                  ext_frame_RAM0_addr    ,
	output logic [31:0]                  ext_frame_RAM0_data    ,
                                                              
  input  logic                         ext_frame_RAM1_cs_n    ,
  input  logic                         ext_frame_RAM1_wr      ,
	input  logic [13:0]                  ext_frame_RAM1_addr    ,
	output logic [31:0]                  ext_frame_RAM1_data    ,
                                                              
	input  logic [31:0]                  dis_frame_RAM_din      ,

  // ---------------------------------------------------------------------------
  // Buffer Interface
  // ---------------------------------------------------------------------------
  output logic                         buffer_mem_req_valid_o ,
  output logic [acc_addr_width-1:0]    buffer_mem_req_addr_o  ,
  output logic [acc_addr_width/8-1:0]  buffer_mem_req_wmask_o ,
  output logic [63:0]                  buffer_mem_req_data_o  ,
  input  logic                         buffer_mem_req_ready_i ,
  output logic                         buffer_mem_req_cmd_o   ,

  input  logic                         buffer_mem_rsp_valid_i ,  
  input  logic [63:0]                  buffer_mem_rsp_data_i  ,
  input  logic                         buffer_mem_rsp_err_i   ,

  // ---------------------------------------------------------------------------
  // RAM0 Interface
  // ---------------------------------------------------------------------------
  output logic                         ram0_mem_req_valid_o   ,
  output logic [acc_addr_width-1:0]    ram0_mem_req_addr_o    ,
  output logic [7:0]                   ram0_mem_req_wmask_o   ,
  output logic [63:0]                  ram0_mem_req_data_o    ,
  input  logic                         ram0_mem_req_ready_i   ,
  output logic                         ram0_mem_req_cmd_o     ,
                                                              
  input  logic                         ram0_mem_rsp_valid_i   ,  
  input  logic [63:0]                  ram0_mem_rsp_data_i    ,
  input  logic                         ram0_mem_rsp_err_i     ,

  // ---------------------------------------------------------------------------
  // RAM1 Interface
  // ---------------------------------------------------------------------------
  output logic                         ram1_mem_req_valid_o   ,
  output logic [acc_addr_width-1:0]    ram1_mem_req_addr_o    ,
  output logic [7:0]                   ram1_mem_req_wmask_o   ,
  output logic [63:0]                  ram1_mem_req_data_o    ,
  input  logic                         ram1_mem_req_ready_i   ,
  output logic                         ram1_mem_req_cmd_o     ,

  input  logic                         ram1_mem_rsp_valid_i   ,  
  input  logic [63:0]                  ram1_mem_rsp_data_i    ,
  input  logic                         ram1_mem_rsp_err_i
);
  // ---------------------------------------------------------------------------
  // Buffer Interface
  // ---------------------------------------------------------------------------
  assign buffer_mem_req_valid_o = buffer_req_start_i & ~bitstream_ram_ren_n;
  assign buffer_mem_req_cmd_o   = 1'b1; // read?
  assign buffer_mem_req_addr_o  = {15'd0, bitstream_ram_addr[16:2], 2'b00}; // bank 0
  assign buffer_mem_req_wmask_o = 4'b1111;
  assign buffer_mem_req_data_o  = '0;
  
	logic [16:0] bitstream_ram_addr_r;
  always @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
         bitstream_ram_addr_r <= '0;
      end else begin
         bitstream_ram_addr_r <= bitstream_ram_addr;
      end
  end
  
  always @(*) begin
      case (bitstream_ram_addr_r[1:0])
          2'b00: bitstream_buffer_input = buffer_mem_rsp_data_i[63:48];
          2'b01: bitstream_buffer_input = buffer_mem_rsp_data_i[47:32];
          2'b10: bitstream_buffer_input = buffer_mem_rsp_data_i[31:16];
          2'b11: bitstream_buffer_input = buffer_mem_rsp_data_i[15:0];
      endcase
  end

  // ---------------------------------------------------------------------------
  // RAM0 Interface
  // ---------------------------------------------------------------------------
  assign ram0_mem_req_valid_o = ~ext_frame_RAM0_cs_n;
  assign ram0_mem_req_cmd_o   = ~ext_frame_RAM0_wr;
  assign ram0_mem_req_addr_o  = {17'd0, ext_frame_RAM0_addr[13:1], 2'b01}; // bank 1
  // assign ram0_mem_req_addr_o  = ext_frame_RAM0_addr[13] ? {17'd0, 3'b001, ext_frame_RAM0_addr[10:1], 2'b11} : // 8192-9503: bank 3 (low)
  //                                                         {17'd0, ext_frame_RAM0_addr[13:1],         2'b01} ; // 0   -8191: bank 1
  assign ram0_mem_req_wmask_o = ext_frame_RAM0_addr[0] ? {4'b1111, 4'b0000}         : {4'b0000, 4'b1111};
  assign ram0_mem_req_data_o  = ext_frame_RAM0_addr[0] ? {dis_frame_RAM_din, 32'd0} : {32'd0, dis_frame_RAM_din};
  
	logic [13:0] ext_frame_RAM0_addr_r;
  always @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
         ext_frame_RAM0_addr_r <= '0;
      end else begin
         ext_frame_RAM0_addr_r <= ext_frame_RAM0_addr;
      end
  end

  assign ext_frame_RAM0_data = ext_frame_RAM0_addr_r[0] ? ram0_mem_rsp_data_i[63:32] : ram0_mem_rsp_data_i[31:0];

  // ---------------------------------------------------------------------------
  // RAM1 Interface
  // ---------------------------------------------------------------------------
  assign ram1_mem_req_valid_o = ~ext_frame_RAM1_cs_n;
  assign ram1_mem_req_cmd_o   = ~ext_frame_RAM1_wr;
  assign ram1_mem_req_addr_o  = {17'd0, ext_frame_RAM1_addr[13:1], 2'b10};  // bank 2
  // assign ram1_mem_req_addr_o  = ext_frame_RAM1_addr[13] ? {17'd0, 3'b001, ext_frame_RAM1_addr[10:1], 2'b11} : // 8192-9503: bank 3 (high)
  //                                                         {17'd0, ext_frame_RAM1_addr[13:1],         2'b10} ; // 0   -8191: bank 2
  assign ram1_mem_req_wmask_o = ext_frame_RAM1_addr[0] ? {4'b1111, 4'b0000}         : {4'b0000, 4'b1111};
  assign ram1_mem_req_data_o  = ext_frame_RAM1_addr[0] ? {dis_frame_RAM_din, 32'd0} : {32'd0, dis_frame_RAM_din};
  
	logic [13:0] ext_frame_RAM1_addr_r;
  always @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
         ext_frame_RAM1_addr_r <= '0;
      end else begin
         ext_frame_RAM1_addr_r <= ext_frame_RAM1_addr;
      end
  end

  assign ext_frame_RAM1_data = ext_frame_RAM1_addr_r[0] ? ram1_mem_rsp_data_i[63:32] : ram1_mem_rsp_data_i[31:0];


endmodule
