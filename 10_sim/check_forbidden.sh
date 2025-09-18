#!/usr/bin/env bash
set -e
if grep -Rnw --include='*.sv' --include='*.v' -E '\b(for|generate)\b' 00_src; then
  echo 'ERROR: "for" or "generate" found in 00_src — not allowed.' >&2
  exit 1
fi
echo 'OK: no for/generate found in 00_src'

