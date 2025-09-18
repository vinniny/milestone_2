# Makefile
SIM ?= icarus          # icarus | verilator
TOP ?= tb/cpu_tb.sv
TOP      ?= cpu_tb
RTL_DIR  := rtl
TB_DIR   := tb
SIM_DIR  := sim
BUILD    := build
SOURCES  := $(RTL_DIR)/regfile.sv $(RTL_DIR)/alu.sv $(TB_DIR)/cpu_tb.sv

IVERILOG ?= iverilog
VVP      ?= vvp
VERILATOR?= verilator

.PHONY: all lint sim clean

all: sim

$(BUILD):
	@mkdir -p $(BUILD)

$(SIM_DIR):
	@mkdir -p $(SIM_DIR)

lint:
	$(VERILATOR) --lint-only -Wall -Wno-UNUSED -Wno-ASSIGNDLY $(SOURCES)

sim: $(BUILD) $(SIM_DIR) $(SOURCES)
	$(IVERILOG) -g2012 -Wall -o $(BUILD)/$(TOP).vvp $(SOURCES)
	$(VVP) $(BUILD)/$(TOP).vvp | tee $(SIM_DIR)/run.log

clean:
	rm -rf $(BUILD) $(SIM_DIR) obj_dir
RTL := $(wildcard rtl/*.sv) $(wildcard rtl/*.v)
TB  := $(TOP)

# output
BUILD := sim
BIN   := $(BUILD)/simv

.PHONY: all run build clean lint waves

all: run

$(BUILD):
\t@mkdir -p $(BUILD)

build: $(BUILD)
ifeq ($(SIM),icarus)
\tiverilog -g2012 -o $(BIN) $(RTL) $(TB)
else ifeq ($(SIM),verilator)
\tverilator -Wall --cc --exe --build -o sim_main $(TB) $(RTL) ; \
\tcp obj_dir/sim_main $(BIN)
else
\t$(error Set SIM=icarus or SIM=verilator)
endif

run: build
ifeq ($(SIM),icarus)
\tvvp $(BIN)
else
\t$(BIN)
endif

lint:
\tverilator --lint-only $(RTL)

clean:
\trm -rf $(BUILD) obj_dir *.vcd *.fst *.log
