
module mem_sync_read #(
  parameter data_width_p = 64,
  parameter depth_p      = 8192, 
  parameter mask_width_p = data_width_p/8,
  parameter addr_width_p = $clog2(depth_p)
) (
  input                       clk_i,

  input                       req_i,
  input                       wen_i,
  input  [addr_width_p-1:0]   addr_i,
  input  [data_width_p-1:0]   wdata_i,
  input  [mask_width_p-1:0]   mask_i,
  output [data_width_p-1:0]   rdata_o
);

  (* ram_style = "block" *) reg  [data_width_p-1:0] ram [depth_p];
  logic [data_width_p-1:0] rdata;
  assign rdata_o = rdata;

  always @(posedge clk_i) begin
    if (req_i) begin
      if (wen_i) begin
        for (integer i = 0; i < mask_width_p; i++) begin
          if (mask_i[i]) begin
            ram[addr_i][i*8 +: 8] <= wdata_i[i*8 +: 8];
          end
        end
      end

      else begin
        rdata <= ram[addr_i];
      end
    end
  end


endmodule
