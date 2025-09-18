TOP      ?= 01_bench/cpu_tb.sv
RTL_DIR  := 00_src
TB_DIR   := 01_bench
SIM_DIR  := 10_sim
BUILD    := 10_sim
SOURCES  := $(wildcard $(RTL_DIR)/*.sv) $(TOP)

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
	$(VERILATOR) --lint-only -Wall -Wno-UNUSED -Wno-ASSIGNDLY -Wno-STMTDLY --top-module cpu_tb $(SOURCES)

sim run: $(BUILD) $(SOURCES)
	$(IVERILOG) -g2012 -Wall -o $(BUILD)/simv $(SOURCES)
	$(VVP) $(BUILD)/simv | tee $(SIM_DIR)/run.log

build: sim

clean:
	rm -rf $(BUILD) $(SIM_DIR) obj_dir *.vcd *.fst *.log
