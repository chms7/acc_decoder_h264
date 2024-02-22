# Directory
PRJ_DIR := $(shell pwd)
RTL_DIR := $(PRJ_DIR)/rtl
TB_DIR  := $(PRJ_DIR)/rtl/tb
SIM_DIR := $(PRJ_DIR)/sim

# RTL
RTL_V		:= $(wildcard $(RTL_DIR)/decoder/*.*v)
RTL_V		+= $(wildcard $(RTL_DIR)/utils/pkg/*.*v)
RTL_V		+= $(wildcard $(RTL_DIR)/utils/*.*v)
RTL_V		+= $(wildcard $(RTL_DIR)/*.*v)

# Testbench
TB   		:= acc
TB_V  	:= $(wildcard $(TB_DIR)/tb_$(TB).sv)

# Tools
SIM_TOOL  := vcs
SIM_FLAGS := -full64 +v2k -sverilog -kdb -fsdb -ldflags -debug_access+all -LDFLAGS \
						 -Wl,--no-as-needed -Mdir=$(SIM_DIR)/csrc +incdir+$(RTL_DIR)/decoder+$(RTL_DIR)+$(RTL_DIR)/utils/pkg
WAVE_TOOL ?= gtkwave

all: sim

sim:
	@mkdir -p sim
	$(SIM_TOOL) $(SIM_FLAGS) \
		$(TB_V) $(RTL_V) -o $(SIM_DIR)/simv && $(SIM_DIR)/simv

wave:
	nohup $(WAVE_TOOL) $(SIM_DIR)/wave.vcd > $(SIM_DIR)/wave_nohup &

view: test/hex2bin
	./test/hex2bin
	nohup YUView nova300.yuv > $(SIM_DIR)/yuv_nohup &

test/hex2bin: test/hex2bin.cpp
	gcc -o $@ $<
	
clean:
	rm -rf sim *.log *.yuv ucli.key
	
.PHONY: all sim wave clean
