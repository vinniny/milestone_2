# Makefile
SIM ?= icarus          # icarus | verilator
TOP ?= tb/cpu_tb.sv

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
