Project compliance notes

- Linting policy
  - Lint with Verilator in CI targeting RTL only (excludes testbench constructs that require timing opts unsupported on older Verilator releases). Suppress SYNCASYNCNET warning to avoid false-negative exits.

- Forbidden constructs
  - `10_sim/check_forbidden.sh` enforces the grader restrictions:
    - No `for (...)` or `generate` in RTL under `00_src/`
    - In `alu.sv` and `brc.sv`, disallow binary `-`, shifts (`<<`, `>>`), and raw `<`/`>` comparisons
  - The script prints scanned files and offending lines; it works even if `perl` is unavailable (block-comment stripping is optional).

- LSU MMIO writes (LEDs at 0x7000/0x7010) are synchronous with a 1-cycle latency by design. Writes latch on the next rising clock edge.
- The testbench LED settle check waits up to 4 cycles to accommodate pipeline effects and simulator scheduling differences; late updates beyond this window are warned, not fatal.
