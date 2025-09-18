TOP      ?= cpu_tb
RTL_DIR  := rtl
TB_DIR   := tb
SIM_DIR  := sim
BUILD    := build
SOURCES  := $(RTL_DIR)/regfile.sv $(RTL_DIR)/alu.sv $(RTL_DIR)/pc.sv $(RTL_DIR)/imem.sv $(RTL_DIR)/dmem.sv $(RTL_DIR)/cpu_top.sv $(TB_DIR)/cpu_tb.sv

IVERILOG ?= iverilog
VVP      ?= vvp
VERILATOR?= verilator

.PHONY: all lint sim clean run build

all: sim

$(BUILD):
	@mkdir -p $(BUILD)

$(SIM_DIR):
	@mkdir -p $(SIM_DIR)

lint:
	$(VERILATOR) --lint-only -Wall -Wno-UNUSED -Wno-ASSIGNDLY -Wno-STMTDLY $(SOURCES)

sim run: $(BUILD) $(SIM_DIR) $(SOURCES)
	$(IVERILOG) -g2012 -Wall -o $(BUILD)/$(TOP).vvp $(SOURCES)
	$(VVP) $(BUILD)/$(TOP).vvp | tee $(SIM_DIR)/run.log

build: sim

clean:
	rm -rf $(BUILD) $(SIM_DIR) obj_dir *.vcd *.fst *.log
