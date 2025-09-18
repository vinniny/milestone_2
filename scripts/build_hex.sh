#!/usr/bin/env bash
set -euo pipefail

# Build RISC-V assembly or C into a Verilog-usable hex file.
# Usage: scripts/build_hex.sh input.S output.hex

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <input.(S|c)> <output.hex> [entry]" >&2
  exit 1
fi

IN="$1"
OUT="$2"
ENTRY="${3-_start}"

RISCV_PREFIX=${RISCV_PREFIX:-riscv32-unknown-elf-}
CC="${RISCV_PREFIX}gcc"
OBJCOPY="${RISCV_PREFIX}objcopy"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

"$CC" -march=rv32i -mabi=ilp32 -nostdlib -Wl,-Ttext=0x0 -Wl,-e,$ENTRY -Os -o "$TMP/a.out" "$IN"
"$OBJCOPY" -O verilog "$TMP/a.out" "$OUT"
echo "Wrote $OUT"

