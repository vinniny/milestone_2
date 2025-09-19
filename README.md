# Milestone 2 – Single‑Cycle RV32I (SV)

Overview
- Runnable single‑cycle RV32I skeleton with lint (Verilator), sim (Icarus), forbidden‑ops guard, and CI.
- Core modules: `singlecycle`, `alu` (no -,<,>,<<,>>), `add32`, `shifter32`, `immgen` (I/S/B/U/J), `brc` (XOR‑reduce eq + add flags), `regfile`, `imem`, `lsu`, `pc_core`/`pc_adder`.

Requirements
- Simulation: `iverilog`, `vvp`
- Lint: `verilator`
- Optional: RISC‑V toolchain (`riscv32-unknown-elf-gcc`, `objcopy`) for `scripts/build_hex.sh`

Quickstart
- Lint: `make lint` (RTL-only lint on older Verilator; TB lint intentionally excluded)
- Run (Icarus default): `make run`
  - ROM loads `02_test/dump/mem.dump` by default; override via make var: `make run HEX=path/to.hex`
  - Prevent hangs: wall-clock timeout via `TIMEOUT` (seconds), TB watchdog via `+TB_MAX_CYCLES`
    - Examples: `make run TIMEOUT=120 VVPARGS='+TB_MAX_CYCLES=50000'`

LED Demo
- Program: `02_test/asm/led_demo.S` (writes RED=1 @0x7000 and GREEN=2 @0x7010, then loops)
- Hex/dump (prebuilt minimal): `02_test/dump/mem.dump`
- Build new dump (if toolchain installed):
  - `./scripts/build_hex.sh 02_test/asm/led_demo.S 02_test/dump/mem.dump`
- Expected sim output:
  - Early valid IF lines (no x)
  - `CHECK: RED LEDs latched 0x00000001 ...`
  - `CHECK: GREEN LEDs latched 0x00000002 ...`
  - `PASS: LED checks and insn_vld OK`

Repo Layout
- `00_src/` — RTL (singlecycle, alu, add32, shifter32, immgen, brc, regfile, imem, lsu, pc_core/pc_adder)
- `01_bench/` — testbenches (`cpu_tb.sv` self‑checks and prints)
- `02_test/asm/` — example programs (e.g., `led_demo.S`)
- `02_test/dump/` — ROM images (`mem.dump`)
- `10_sim/` — sim build artifacts (simv, logs)
- `20_syn/quartus/` — DE2 scaffolding (README)
- `99_doc/` — docs and notes (`NOTES.md`)

Forbidden‑Ops Policy (ALU/BRC)
- ALU: no `-`, `<`, `>`, `<<`, `>>`
  - SUB = `a + ~b + 1` via `add32`
  - Shifts via `shifter32` (5‑stage mux barrel)
  - SLT/SLTU via add flags (N^V, ~Cout)
- BRC: equality via XOR‑reduction; less via subtract flags from `add32`

Memory Map (LSU)
- 0x2000–0x3FFF: 8 KiB RAM (SW/LW only; clk’d writes, async reads; implemented inside `lsu.sv`)
- 0x7000–0x700F: RED LEDs (write)
- 0x7010–0x701F: GREEN LEDs (write)
- 0x7020–0x7027: Seven‑seg (stub)
- 0x7030–0x703F: LCD regs (stub)
- 0x7800–0x780F: Switches (read)
- 0x7810–0x781F: Buttons (read)

Datapath Snapshot
- IF: `pc` +4, `imem` ROM (8 KiB); plusarg `+HEX` override
- Decode: `control.sv` (RV32I), `immgen` (I/S/B/U/J)
- EX: `alu` (add32, shifter32), `brc` (add32 flags)
- MEM: `lsu` (RAM + IO), `imem`
- WB: ALU / Load / PC+4
- Robust JAL/JALR/Branch PC select: control OR local opcode detect (guards against wiring mismatches)

CI & Guards
- Workflow: `.github/workflows/ci.yml` (verilog‑ci)
  - Steps: install tools, forbidden‑ops guard, lint (Verilator), run (Icarus)
- Forbidden‑ops guard: `10_sim/check_forbidden.sh` (blocks `for`/`generate` in `00_src/`; now verbose and resilient if `perl` is missing)

Compliance
- The generated compliance matrix lives at `99_doc/COMPLIANCE.md` (run `make compliance` to refresh).
