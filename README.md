# Milestone 2 – Single-Cycle RV32I

Quickstart
- Requirements: `iverilog`, `verilator` (for lint), optional RISC-V toolchain (`riscv32-unknown-elf-gcc`, `objcopy`) for `scripts/build_hex.sh`.
- Build and run smoke test: `make sim` (expects PASS)
- Lint with Verilator: `make lint`

Layout
- `rtl/`: simple modules (`regfile.sv`, `alu.sv`)
- `tb/`: testbenches (`cpu_tb.sv` smoke test)
- `asm/`: assembly/C inputs (for future programs)
- `sim/`: simulation outputs (gitignored)
- `docs/refs/`: references and docs
- `scripts/`: helper scripts (`build_hex.sh`)
- `.github/workflows/`: CI setup
# milestone_2
