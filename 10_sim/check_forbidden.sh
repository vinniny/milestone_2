#!/usr/bin/env bash
set -euo pipefail

fail=0
while IFS= read -r -d '' f; do
  # Strip line comments //... and same-line /* ... */; cheap but effective here.
  filtered="$(sed -E 's://.*$::; s:/\*[^*]*\*/::g' "$f")"
  if echo "$filtered" | grep -nE '\b(for|generate)\b' >/dev/null; then
    echo "ERROR: forbidden token in $f"
    echo "$filtered" | nl -ba | grep -nE '\b(for|generate)\b' | sed -E 's/^/  /'
    fail=1
  fi
done < <(find 00_src -type f \( -name '*.sv' -o -name '*.v' \) -print0)

if [ $fail -ne 0 ]; then
  echo 'FAIL: "for" or "generate" found (excluding comments).'
  exit 1
fi

echo 'OK: no for/generate found in 00_src (comments ignored).'
