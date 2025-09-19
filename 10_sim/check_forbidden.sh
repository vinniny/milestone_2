#!/usr/bin/env bash
set -euo pipefail
fail=0
strip(){ sed -E 's://.*$::' "$1" | perl -0777 -pe 's:/\*.*?\*/::gs'; }
scan(){ t="$(strip "$1")";
  grep -nE '\bfor\s*\(' <<<"$t" && { echo "ERROR: for in $1"; fail=1; }; true
  grep -nE '\bgenerate\b' <<<"$t"   && { echo "ERROR: generate in $1"; fail=1; }; true
  case "$(basename "$1")" in alu.sv|brc.sv)
    grep -nE '(^|[^<>=!])-|<<|>>|(^|[^<>=!])[<>][[:alnum:]_()]' <<<"$t" \
      && { echo "ERROR: forbidden op in $1"; fail=1; };;
  esac
}
while IFS= read -r -d '' f; do scan "$f"; done < <(find 00_src -name '*.sv' -print0)
((fail)) && { echo "FAILED: grader restrictions violated."; exit 1; } || echo "OK: forbidden construct checks passed."
