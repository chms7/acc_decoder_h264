
module dtcm_banks #(
  parameter  bank_size_p   = 1024, // bytes
  parameter  bank_num_p    = 4,
  parameter  data_width_p  = 64,
  parameter  bank_words_p  = bank_size_p/4,
  parameter  addr_width_p  = $clog2(bank_words_p), // word addr
  parameter  mask_width_p  = data_width_p/8
) (
  input                                       clk_i,
  input                                       rst_ni,

  input   [bank_num_p-1:0]                    req_i, 
  output  [bank_num_p-1:0]                    gnt_o, 
  input   [bank_num_p-1:0][addr_width_p-1:0]  addr_i,
  input   [bank_num_p-1:0]                    wen_i,
  input   [bank_num_p-1:0][data_width_p-1:0]  wdata_i,
  input   [bank_num_p-1:0][mask_width_p-1:0]  mask_i, 
  output  [bank_num_p-1:0][data_width_p-1:0]  rdata_o
);
  
  for (genvar i = 0; i < bank_num_p; i++) begin : banks

    assign gnt_o[i] = 1'b1;

    mem_sync_read #(
      .data_width_p ( data_width_p ),
      .depth_p      ( bank_words_p )
    ) bank_i (
      .clk_i    ( clk_i       ),
      .req_i    ( req_i   [i] ),
      .wen_i    ( wen_i   [i] ),
      .addr_i   ( addr_i  [i] ),
      .wdata_i  ( wdata_i [i] ),
      .mask_i   ( mask_i  [i] ),
      .rdata_o  ( rdata_o [i] )
    );

  end

endmodule

