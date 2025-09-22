#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/wl" ]; then
  exec "$HOME/bin/wl" "$@"
fi
echo "wl shim: missing $HOME/bin/wl" >&2
exit 127

