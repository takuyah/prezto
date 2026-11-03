#!/usr/bin/env bash
# Parse every Prezto-owned zsh file with `zsh -n` (no execution).
# Third-party code under modules/*/external is skipped.
set -u
cd "$(dirname "$0")/../.."

status=0
while IFS= read -r -d '' file; do
  if ! zsh -n "$file"; then
    echo "::error file=$file::zsh syntax error"
    status=1
  fi
done < <(
  find init.zsh runcoms modules \
    -path '*/external' -prune -o \
    -type f \( -name '*.zsh' -o -path '*/functions/*' -o -path 'runcoms/z*' \) \
    -print0
)
exit $status
