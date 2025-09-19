Scope & Precedence

Applies to the entire repository.
Milestone‑2 spec in 99_doc/milestone-2.md is top priority. When in doubt, match it.
Follow these rules before adding new ideas or refactors.

Mission

Maintain a runnable single‑cycle RV32I core that:
Uses logic‑only arithmetic in ALU/BRC and PC path (see Constraints).
Implements LSU with the specified memory map.
Builds, lints, and runs under the provided Makefile/CI.
Times out cleanly if a sim hangs; treat timeouts as failures.

Design Philosophy

- RISC-V is intentionally modular and minimal; stick to the RV32I base ISA so the code remains easy to reason about and teach (see 99_doc/refs/The-RISC-V-Reade-An-open-Architecture-Atlas.pdf).
- Align the datapath with textbook single-cycle diagrams from 99_doc/refs/Digital Design & Computer Architecture RISC-V Edition.pdf: clean separation of PC, instruction memory, control, immgen, ALU, branch, LSU, and register file.
- Prioritize correctness and observability; every addition should be verifiable via simulation before considering performance tweaks (reinforced in 99_doc/refs/HandP_RISCV.pdf).

Repo Map (authoritative)

00_src/ RTL you may edit:
singlecycle.sv (top, required I/O)
pc_core.sv (PC register, async active‑low reset)
pc_adder.sv (PC+4 via add32 — no ‘+’)
add32.sv (gate‑level 32‑bit adder)
alu.sv (no -, <, >, <<, >>; uses add32 and shifter32)
shifter32.sv (barrel shifter by mux stages)
immgen.sv (I/S/B/U/J immediates)
brc.sv (XOR‑reduce equality; less from subtract flags via add32)
regfile.sv (32×32, 2R1W, x0=0)
imem.sv (8 KiB ROM, +HEX or default dump)
lsu.sv (8 KiB RAM @ 0x2000–0x3FFF + MMIO map; bit‑slice decode)
01_bench/cpu_tb.sv Testbench with watchdog (+TB_MAX_CYCLES).
scripts/:
gen_compliance.sh writes 99_doc/COMPLIANCE.md after guard/lint/run.
build_hex.sh builds RISC‑V programs into Verilog hex.
Makefile: lint, run (with TIMEOUT), compliance.
.github/workflows/ci.yml: CI uses timeouts and TB watchdog.

Top‑Level Contract

Module: singlecycle
Ports (exact per milestone‑2):
Inputs: i_clk, i_rst_n, i_io_sw[31:0], i_io_btn[3:0]
Outputs: o_pc_debug[31:0], o_insn_vld, o_io_ledr[31:0], o_io_ledg[31:0], o_io_hex0..7[6:0], o_io_lcd[31:0]
PC pipeline:
pc_core holds PC; pc_adder computes PC+4 via add32.
Next‑PC targets (pc+imm, rs1+imm) computed with add32 (no ‘+’).
JALR target masked with & 32'hFFFF_FFFE.

Design Constraints

ALU/BRC/PC path:
Do not use built‑in -, <, >, <<, >>.
Use add32 for add/sub; shifter32 for shifts; SLT via flags.
Prefer avoiding ‘+’ in PC datapath; current design uses add32.
No for or generate in 00_src/.
Reset/clocking:
Use logic types; always_ff with posedge clk and async negedge rst_n only where needed.
always_comb for combinational logic; no latches.
LSU memory map:
RAM: 0x2000–0x3FFF (8 KiB), word‑aligned index i_addr[12:2].
RED LEDs 0x7000..0x700F; GREEN 0x7010..0x701F; Seven‑seg 0x7020..0x7027; LCD 0x7030..0x703F; SW 0x7800..0x780F; BTN 0x7810..0x781F.
Use bit‑slice address decodes (no range arithmetic).

Coding Guidelines

- Start each RTL file with `` `timescale 1ns/1ps`` and keep module-per-file organization (Verilog Digital System Design best practice).
- Use `logic` types; partition sequential logic into `always_ff @(posedge clk or negedge rst_n)` and combinational into `always_comb`. Never infer latches.
- Avoid `for`/`generate` in 00_src/; unroll structures manually or leverage helper modules (guidance from RTL Modeling with SystemVerilog).
- Keep datapath and control separated inside modules; use clearly named wires that mirror textbook figures (Digital Design & Computer Architecture RISC-V Edition).
- Prefer structural arithmetic (add32, shifter32) over built-in operators; this reinforces the “logic-only” ALU rule and maintains synthesizability.
- Use explicit literal sizes (e.g., `32'h0000_0000`) and consistent endianness for bus concatenations.
- Gate optional debug or assertions with `ifdef` blocks so synthesis flows stay clean.
- Maintain concise comments explaining intent or non-obvious constraints; avoid narrating obvious assignments.
- Follow existing naming (prefix `i_`, `o_`, `lsu_*`) to keep TB/CI hooks valid.

Verification & Simulation

- Testbenches should be self-checking with deterministic finish conditions; mirror `01_bench/cpu_tb.sv` structure (clock gen, reset pulse, monitors) per Verilog Digital System Design guidance.
- Incorporate SystemVerilog assertions or immediate checks for key invariants (e.g., PC alignment, LED response latency); guard them with `ifdef ASSERTIONS` so they can be enabled in CI without affecting synthesis.
- Leverage functional coverage or simple counters to confirm instruction classes execute when adding new tests (SystemVerilog for Verification).
- Use `make lint` (Verilator) as a pre-flight; keep lint clean by resolving warnings instead of suppressing them, documenting any necessary waivers.
- CI sequence (guard → lint → sim) must stay green before merging; run `make compliance` locally when unsure to replicate the workflow.
- For iterative debug, add scoped `$display` statements keyed to opcode types; remove noisy traces before final submission.

System Integration

- LSU remains the single point for data memory and peripherals; follow the memory map exactly and keep decoders purely combinational.
- Treat RAM (0x2000–0x3FFF) as word-addressed SRAM; read combinationally, write on positive clock when `lsu_we` is asserted.
- Honor side-effect ordering: LED writes latch in the same cycle; seven-seg and LCD stubs accept data but may hold previous state until fully implemented.
- Control path must supply properly sign-extended immediates via `immgen`, and branch decisions via `brc`; ensure `control.sv` toggles `pc_src_branch/jal/jalr` per instruction type.
- Keep IMEM (`imem.sv`) purely read-only ROM with $readmemh initialization; fail fast on X detection to avoid undefined execution.
- Maintain the single-cycle flow (IF → ID → EX → MEM → WB) derived from Digital Design & Computer Architecture RISC-V Edition, ensuring module boundaries align with that datapath.

Build, Lint, Run

Lint: make lint (Verilator; RTL only).
Run: make run
Default ROM: 02_test/dump/mem.dump
Override: make run HEX=path/to.hex
Plusargs: make run VVPARGS='+TB_MAX_CYCLES=50000'
Timeout: make run TIMEOUT=120
Treat any timeout (wall‑clock or TB watchdog) as a failure that needs fixing.

Compliance & Docs

Generate matrix: make compliance (runs guard, lint, sim; writes 99_doc/COMPLIANCE.md).
Keep README.md aligned (core modules, memory map, run instructions).
Update scripts/gen_compliance.sh if module lists change.
Do not add license headers unless asked.

Change Policy

If you add/remove RTL files, update the Makefile RTL list.
Do not change top‑level port names/types.
Keep singlecycle as the only top in sources and CI.
Avoid adding new dependencies; use shipped tools.

Common Tasks

Add a new datapath helper:
Put in 00_src/, wire from singlecycle.sv.
Use logic types; no forbidden constructs.
Add to Makefile under RTL :=.
Lint and run sim; regenerate compliance.
Modify LSU mapping:
Use bit‑slice compares; keep writes clocked, reads combinational.
Update README and compliance notes if address ranges change.

Memory Map Quick Reference

ROM 0x0000–0x1FFF (IMEM, 8 KiB)
RAM 0x2000–0x3FFF (LSU, 8 KiB)
RED 0x7000–0x700F; GREEN 0x7010–0x701F
HEX 0x7020–0x7027; LCD 0x7030–0x703F
SW 0x7800–0x780F; BTN 0x7810–0x781F

Validation Checklist (before opening a PR)

Builds: make lint passes.
Runs: make run completes without timeout; TB prints PASS line.
Guard: 10_sim/check_forbidden.sh passes (no for/generate, no forbidden ops).
Docs: README and compliance updated if you changed modules or behavior.
No reintroduction of removed/unused files; no directory churn.

Getting Started (new contributors)

1. Read 99_doc/milestone-2.md end-to-end; it is the grading contract and defines every interface.
2. Skim README.md for the repo map and quickstart commands.
3. Build toolchain: ensure iverilog, vvp, verilator, and (optionally) riscv32-unknown-elf-gcc/objcopy are installed.
4. Run `make lint` then `make run` from a clean clone; expect the LED PASS banner and no timeouts.
5. Browse 01_bench/cpu_tb.sv to understand TB expectations (hierarchical probes, watchdogs, LED checks).
6. Review key RTL modules in 00_src/ to see coding patterns (logic types, add32-based arithmetic, bit-slice decoders).

Reference Materials (worth reviewing)

- 99_doc/refs/HandP_RISCV.pdf — Patterson & Hennessy overview of RV32I.
- 99_doc/refs/Digital Design & Computer Architecture RISC-V Edition.pdf — pipeline diagrams, immediate encodings.
- 99_doc/refs/SystemVerilogforVerification.pdf plus 99_doc/refs/verilog digital system design.pdf — syntax refresher.
- 99_doc/refs/milestone-2.pdf — original assignment PDF with figures and memory map tables.
- 99_doc/refs/Reconfigurable Computing... pdfs — optional background for FPGA deployment.
- 99_doc/LEARNED_FROM_TEAM.md and 99_doc/NOTES.md — distilled lessons from earlier iterations.

Simulation Flow Summary

1. `make run` compiles RTL + TB with Icarus, loads ROM via `+HEX=02_test/dump/mem.dump` unless overridden.
2. TB asserts reset for 4 cycles, prints PC trace, watches LEDs, and finishes at cycle 2000 or on failure.
3. Timeouts: Makefile wraps vvp with `timeout` when available; TB also has a `+TB_MAX_CYCLES` watchdog.
4. Logs show `CHECK: RED LEDs...` and `CHECK: GREEN LEDs...` before the PASS message; missing prints indicate LSU or program issues.

Workflow Tips

- Use small commits per module; run lint/sim between edits to keep bisectable.
- When changing control flow (branches, jumps), add temporary `$display` traces mirroring existing style; remove once validated.
- If you update the ROM program, rebuild with `scripts/build_hex.sh` and commit the new dump under 02_test/dump/.
- For Quartus work, keep synthesis artifacts inside 20_syn/quartus/run/ and avoid polluting RTL directories.

Future Extensions

- When ready to pipeline, reuse this single-cycle design as the reference model; add stages incrementally and validate with lockstep comparisons (Hennessy & Patterson pipeline guidance).
- Explore optional RV32 extensions (M, CSR, interrupts) by adding isolated functional units and updating control; maintain fallbacks so milestone functionality remains intact.
- For FPGA targets, evaluate alternative LSU implementations (block RAM, AXI bridges) and document trade-offs per 99_doc/refs/Reconfigurable Computing_ The Theory and Practice of -- André DeHon; Scott Hauck (eds_) -- The Morgan Kaufmann series in systems on silicon.pdf.
- Consider parameterizable modules (e.g., data width, memory depth) while staying within synthesizable subsets; avoid generate loops unless the milestone spec is relaxed.
- Maintain compatibility with existing TBs by keeping interfaces stable; add new verification collateral alongside new features.

Support Contacts

- For spec clarifications: consult milestone doc first, then README, then prior notes.
- For architecture refreshers: see the references above—the Patterson & Hennessy text is the fastest refresher.
- For tooling quirks: scripts/gen_compliance.sh encapsulates the guard/lint/run combo; inspect it if CI fails locally.
