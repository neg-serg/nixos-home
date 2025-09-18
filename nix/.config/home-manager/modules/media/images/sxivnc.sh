#!/usr/bin/env bash
set -euo pipefail
if command -v nsxiv >/dev/null 2>&1; then
  exec nsxiv -n -c "$@"
elif command -v sxiv >/dev/null 2>&1; then
  exec sxiv -n -c "$@"
elif command -v swayimg >/dev/null 2>&1; then
  exec swayimg "$@"
else
  echo "sxivnc: no nsxiv/sxiv/swayimg in PATH" >&2
  exit 127
fi
