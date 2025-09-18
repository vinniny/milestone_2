SIM ?= icarus
TOP ?= 01_bench/cpu_tb.sv
RTL := $(wildcard 00_src/*.sv) $(wildcard 00_src/*.v)
TB  := $(TOP)
BUILD := 10_sim
BIN   := $(BUILD)/simv

.PHONY: all run build clean lint
all: run

$(BUILD):
	@mkdir -p $(BUILD)

build: $(BUILD)
ifeq ($(strip $(SIM)),verilator)
	@echo "==> Building with Verilator"
	verilator -Wall --cc --exe --build -o sim_main $(TB) $(RTL)
	cp obj_dir/sim_main $(BIN)
else
	@echo "==> Building with Icarus (SIM=$(SIM))"
	iverilog -g2012 -Wall -o $(BIN) $(RTL) $(TB)
endif

run: build
ifeq ($(strip $(SIM)),verilator)
	$(BIN)
else
	vvp $(BIN)
endif

lint:
	verilator --lint-only -Wall -Wno-UNUSED -Wno-ASSIGNDLY -Wno-STMTDLY --top-module cpu_tb $(RTL) $(TB)

clean:
	rm -rf $(BUILD) obj_dir *.vcd *.fst *.log
