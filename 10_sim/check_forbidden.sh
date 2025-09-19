#!/usr/bin/env bash
set -euo pipefail

# More robust and chatty guard: prints file names, checks tools,
# and avoids set -e being tripped by grep non-matches.

need() { command -v "$1" >/dev/null 2>&1 || { echo "FATAL: missing dependency '$1'"; exit 2; }; }
need sed
need grep
need find
# perl is optional; if absent we skip block-comment stripping
has_perl=1
if ! command -v perl >/dev/null 2>&1; then has_perl=0; fi

fail=0
strip() {
  # Remove // line comments first
  local t
  t=$(sed -E 's://.*$::' "$1")
  # Optionally remove /* ... */ block comments if perl is available
  if [[ "$has_perl" -eq 1 ]]; then
    printf '%s' "$t" | perl -0777 -pe 's:/\*.*?\*/::gs'
  else
    # Fallback: no block comment stripping
    printf '%s' "$t"
  fi
}

scan() {
  local file="$1"
  echo "Scanning: $file"
  local t
  t="$(strip "$file")"

  # forbid for (...) loops
  if grep -nE '\bfor\s*\(' <<<"$t" >/dev/null; then
    grep -nE '\bfor\s*\(' <<<"$t" || true
    echo "ERROR: for in $file"
    fail=1
  fi

  # forbid 'generate'
  if grep -nE '\bgenerate\b' <<<"$t" >/dev/null; then
    grep -nE '\bgenerate\b' <<<"$t" || true
    echo "ERROR: generate in $file"
    fail=1
  fi

  # Extra ALU/BRC operator restrictions
  case "$(basename "$file")" in
    alu.sv|brc.sv)
      if grep -nE '(^|[^<>=!])-|<<|>>|(^|[^<>=!])[<>][[:alnum:]_()]' <<<"$t" >/dev/null; then
        grep -nE '(^|[^<>=!])-|<<|>>|(^|[^<>=!])[<>][[:alnum:]_()]' <<<"$t" || true
        echo "ERROR: forbidden op in $file"
        fail=1
      fi
      ;;
  esac
}

while IFS= read -r -d '' f; do scan "$f"; done < <(find 00_src -name '*.sv' -print0)

if ((fail)); then
  echo "FAILED: grader restrictions violated."
  exit 1
else
  echo "OK: forbidden construct checks passed."
fi
