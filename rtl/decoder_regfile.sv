`include "core_defines.vh"       

module decoder_regfile #(
  parameter   dmem_data_width         = 64,
  parameter   acc_inst_width          = `CORE_INSTWIDTH,
  parameter   acc_data_width          = `CORE_DATAWIDTH,
  parameter   acc_addr_width          = `CORE_ADDRWIDTH,
  parameter   acc_regfile_addr_width  = 2
) (
  input  logic                              clk_i,
  input  logic                              rst_ni,
  
  // write
  input  logic                              rf_wr_i,
  input  logic [acc_regfile_addr_width-1:0] rf_wr_idx_i,
  input  logic [acc_data_width-1:0]         rf_wr_data_i,

  // read
  output logic [acc_data_width-1:0]         rf_rd_x0_buffer_req_base_o,
  output logic [acc_data_width-1:0]         rf_rd_x1_buffer_req_end_o ,
  output logic [acc_data_width-1:0]         rf_rd_x2_ram0_req_base_o  ,
  output logic [acc_data_width-1:0]         rf_rd_x3_ram1_req_base_o  
);
  // regfile
  logic [acc_data_width-1:0] regfile [2**acc_regfile_addr_width-1:0];
  
  // wirte
  integer idx;
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      for (idx = 0; idx < acc_regfile_addr_width; idx++)
        regfile[idx] <= '0;
    end else begin
      if (rf_wr_i) begin
        regfile[rf_wr_idx_i] <= rf_wr_data_i;
      end
    end
  end
  
  // read
  assign rf_rd_x0_buffer_req_base_o = regfile[0];
  assign rf_rd_x1_buffer_req_end_o  = regfile[1];
  assign rf_rd_x2_ram0_req_base_o   = regfile[2];
  assign rf_rd_x3_ram1_req_base_o   = regfile[3];
  
endmodule