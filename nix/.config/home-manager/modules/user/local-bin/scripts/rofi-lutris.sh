#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/rofi-lutris" ]; then
  exec "$HOME/bin/rofi-lutris" "$@"
fi
echo "rofi-lutris shim: missing $HOME/bin/rofi-lutris" >&2
exit 127

