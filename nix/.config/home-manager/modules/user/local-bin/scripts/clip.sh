#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/clip" ]; then
  exec "$HOME/bin/clip" "$@"
fi
if command -v cliphist >/dev/null 2>&1 && command -v rofi >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1; then
  cliphist list | rofi -dmenu -matching fuzzy -i -p "Clipboard" -theme clip | cliphist decode | wl-copy || true
  exit 0
fi
echo "clip shim: missing $HOME/bin/clip and no fallback tools available" >&2
exit 127

