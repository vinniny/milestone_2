RTL := 00_src/add32.sv 00_src/alu.sv 00_src/brc.sv 00_src/control.sv \
       00_src/dmem.sv 00_src/imem.sv 00_src/immgen.sv 00_src/lsu.sv \
       00_src/mux_2to1.sv 00_src/mux_3to1.sv \
       00_src/pc_core.sv 00_src/pc_adder.sv 00_src/pc_debug.sv \
       00_src/regfile.sv 00_src/shifter32.sv 00_src/singlecycle.sv
TB  := 01_bench/cpu_tb.sv
TOP := cpu_tb
BUILD := 10_sim
BIN := $(BUILD)/simv
HEX ?= 02_test/dump/mem.dump

.PHONY: run clean lint

run: | $(BUILD)
	iverilog -g2012 -Wall -o $(BIN) -s $(TOP) $(RTL) $(TB)
	vvp $(BIN) +HEX=$(HEX)

lint:
	# Lint only RTL; some TB constructs (delays, forks) require timing opts unsupported by CI verilator
	verilator --lint-only -Wall -Wno-UNUSED -Wno-ASSIGNDLY -Wno-STMTDLY -Wno-SYNCASYNCNET --top-module singlecycle $(RTL)

$(BUILD):
	@mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD) obj_dir *.vcd *.fst *.log

.PHONY: compliance
compliance:
	@./scripts/gen_compliance.sh
