`include "core_defines.vh"

module decoder_inst_interface #(
  parameter   dmem_data_width         = 64,
  parameter   acc_inst_width          = `CORE_INSTWIDTH,
  parameter   acc_data_width          = `CORE_DATAWIDTH,
  parameter   acc_addr_width          = `CORE_ADDRWIDTH,
  parameter   acc_regfile_addr_width  = 2
) (
  input  logic                              clk_i                       ,
  input  logic                              rst_ni                      ,

  // Rocc Command Request Interface
  input  logic                              acc_cmd_req_valid_i         ,
  input  logic [acc_data_width-1:0]         acc_cmd_req_rs1_i           ,
  input  logic [acc_data_width-1:0]         acc_cmd_req_rs2_i           ,
  input  logic [acc_inst_width-1:0]         acc_cmd_req_inst_i          ,
  output logic                              acc_cmd_req_ready_o         ,

  // Rocc Command Response Interface
  output logic                              acc_cmd_rsp_valid_o         ,
  output logic [acc_data_width-1:0]         acc_cmd_rsp_data_o          ,
  input  logic                              acc_cmd_rsp_ready_i         ,
  output logic                              acc_cmd_rsp_err_o           ,
  
  // Regfile
  output logic                              rf_wr_o                     ,
  output logic [acc_regfile_addr_width-1:0] rf_wr_idx_o                 ,
  output logic [acc_data_width-1:0]         rf_wr_data_o                ,

  input  logic [acc_data_width-1:0]         rf_rd_x0_buffer_req_base_i  ,
  input  logic [acc_data_width-1:0]         rf_rd_x1_buffer_req_end_i   ,
  input  logic [acc_data_width-1:0]         rf_rd_x2_ram0_req_base_i    ,
  input  logic [acc_data_width-1:0]         rf_rd_x3_ram1_req_base_i    ,
  
  // Decoder
  input  logic [acc_addr_width-1:0]         acc_lsu_buffer_req_addr_i   ,
  output logic                              buffer_req_start_o          ,
  input  logic                              decode_end_i
);
  // ---------------------------------------------------------------------------
  // Parameters & Defines
  // ---------------------------------------------------------------------------
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
  
  localparam ACC_STATE_IDLE       = 2'b00;
  localparam ACC_STATE_BUF_REQ    = 2'b01;
  localparam ACC_STATE_WAIT_END   = 2'b11;

  // ---------------------------------------------------------------------------
  // Instruction Encode
  // ---------------------------------------------------------------------------
  wire [6:0] inst_opcode   = acc_cmd_req_inst_i[6:0];
  wire [6:0] inst_funct7   = acc_cmd_req_inst_i[31:25];
  wire       inst_xd       = acc_cmd_req_inst_i[14];
  wire       inst_xs1      = acc_cmd_req_inst_i[13];
  wire       inst_xs2      = acc_cmd_req_inst_i[12];

  // regfile idx
  wire [1:0] dec_acc_reg_idx = inst_funct7[1:0];
  
  // write rs1 -> regfile
  wire dec_wr_buf_base   = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_WR_BUF_BASE ) & inst_xs1;
  wire dec_wr_buf_end    = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_WR_BUF_END  ) & inst_xs1;
  wire dec_wr_ram0_base  = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_WR_RAM0_BASE) & inst_xs1;
  wire dec_wr_ram1_base  = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_WR_RAM1_BASE) & inst_xs1;
  
  // read regfile -> rd
  wire dec_rd_buf_base   = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_WR_BUF_BASE ) & inst_xd;
  wire dec_rd_buf_end    = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_WR_BUF_END  ) & inst_xd;
  wire dec_rd_ram0_base  = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_WR_RAM0_BASE) & inst_xd;
  wire dec_rd_ram1_base  = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_WR_RAM1_BASE) & inst_xd;
  
  // start decoder
  wire dec_start_decoder = (inst_opcode == OPCODE_CUSTOM3) & (inst_funct7 == FUNCT7_START);
  
  // ---------------------------------------------------------------------------
  // Control FSM
  // ---------------------------------------------------------------------------
  logic [1:0] state_q, state_d;
  
  always @(*) begin
    case (state_q)
      ACC_STATE_IDLE: begin
        if (acc_cmd_req_valid_i)
          state_d = ACC_STATE_BUF_REQ;
        else
          state_d = ACC_STATE_IDLE;
      end
      ACC_STATE_BUF_REQ: begin
        if (acc_lsu_buffer_req_addr_i[16:0] == rf_rd_x1_buffer_req_end_i[16:0])
          state_d = ACC_STATE_WAIT_END;
        else
          state_d = ACC_STATE_BUF_REQ;
      end
      ACC_STATE_WAIT_END: begin
        if (decode_end_i)
          state_d = ACC_STATE_IDLE;
        else
          state_d = ACC_STATE_WAIT_END;
      end
      default: begin
        state_d = ACC_STATE_IDLE;
      end
    endcase
  end
  
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      state_q <= ACC_STATE_IDLE;
    else
      state_q <= state_d;
  end

  // ---------------------------------------------------------------------------
  // Write/Read Regfile
  // ---------------------------------------------------------------------------
  assign rf_wr_o      = acc_cmd_req_valid_i & (dec_wr_buf_base | dec_wr_buf_end | dec_wr_ram0_base | dec_wr_ram1_base);
  assign rf_wr_idx_o  = dec_acc_reg_idx;
  assign rf_wr_data_o = acc_cmd_req_rs1_i;
  
  assign acc_cmd_rsp_data_o = (dec_acc_reg_idx == 2'b00) ? rf_rd_x0_buffer_req_base_i :
                              (dec_acc_reg_idx == 2'b01) ? rf_rd_x1_buffer_req_end_i  :
                              (dec_acc_reg_idx == 2'b10) ? rf_rd_x2_ram0_req_base_i   :
                              (dec_acc_reg_idx == 2'b11) ? rf_rd_x3_ram1_req_base_i   :
                                                           '0                         ;

  // ---------------------------------------------------------------------------
  // Rocc Handshake
  // ---------------------------------------------------------------------------
  assign acc_cmd_req_ready_o = state_q == ACC_STATE_IDLE;
  
  assign acc_cmd_rsp_valid_o = (state_q == ACC_STATE_IDLE    ) & (dec_rd_buf_base | dec_rd_buf_end | dec_rd_ram0_base | dec_rd_ram1_base) |
                               (state_q == ACC_STATE_WAIT_END) &  decode_end_i;

  // always @(posedge clk_i or negedge rst_ni) begin
  //   if (!rst_ni)
  //     acc_cmd_rsp_valid_o = 1'b0;
  //   else if (state_q == ACC_STATE_IDLE)
  //     acc_cmd_rsp_valid_o = dec_rd_buf_base | dec_rd_buf_end | dec_rd_ram0_base | dec_rd_ram1_base;
  //   else if (state_q == ACC_STATE_START)
  //     acc_cmd_rsp_valid_o = decode_end_i;
  //   else
  //     acc_cmd_rsp_valid_o = 1'b0;
  // end

  assign acc_cmd_rsp_err_o   = 1'b0;
  
  assign buffer_req_start_o  = (state_q == ACC_STATE_BUF_REQ);
  
endmodule