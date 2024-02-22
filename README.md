# nova decoder

## 1 解码器

[decoder](https://github.com/freecores/nova) 内部结构的详细文档参见 `nova_spec.doc` 。

## 2 协处理器接口

- `decoder_top.sv` 是协处理器顶层模块，有 1 对 Rocc Command Req/Rsp Interface 指令接口，还有 3 个 LSU Buffer/RAM0/RAM1 访存接口（两读一写）。
- `decoder_regfile.sv` 有4个配置寄存器：
  - `x0_buffer_req_base` ：buffer 访存 bank 0 起始地。
  - `x1_buffer_req_end` ：buffer 访存 bank 0 结束地址。
  - `x2_ram0_req_base` ：ram0访存起始地址，实际是从 0 开始访存 bank 1 ，这个目前没用到。
  - `x3_ram1_req_base` ：ram1访存起始地址，实际是从 0 开始访存 bank 2 ，这个目前没用到。
- `decoder_inst_interface.sv` 解码自定义指令，主要是配置寄存器和 `START` 指令。

```verilog
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
```

- `decoder_lsu.sv` 调整访存地址和数据。

- `ext_frame_RAM_wrapper` 用来记录写入 ram 的帧数据，结果记录在 `nova_display.log` 。使用`test/hex2bin.cpp` 编译出的 `test/hex2bin` 将其转化为 `nova_display.yuv` ，这时就可以用 `YUView` 播放结果视频。

```verilog
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

// ---------------------------------------------------------------------------
// Inside `ext_frame_RAM0_wrapper`
// ---------------------------------------------------------------------------
tracefile_display = $fopen("nova_display.log","a");
	for (j= 0; j < 9504; j= j + 1)begin
		$fdisplay (tracefile_display,"%h",ext_frame_RAM0[j]);
	end
$fclose(tracefile_display);
```

## 3 仿真

### TB

`rtl/tb/tb_acc.sv` 是整个协处理器的 testbench ，其他是之前测试其他部分用的。

### h264 测试文件

`test/akiyo300_1ref.txt` 是一个300帧的 h264 源文件，使用 `test/split_frame.py` 将他们按帧切割成多个文件，但切割后的每个文件不完全与一帧对应， `test/frame` 目录下是手动调整过后的文件，在 tb 里读入 dmem 。

### 仿真

- 仿真

```makefile
make sim
```

- 波形

```makefile
make wave
```

- 播放处理后的视频结果，不过时间很短只有几帧。
  - 需要安装 YUView `sudo apt install yuview` 


```makefile
make view
```
