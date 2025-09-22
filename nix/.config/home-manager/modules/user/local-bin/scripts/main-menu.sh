#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/main-menu" ]; then
  exec "$HOME/bin/main-menu" "$@"
fi
echo "main-menu shim: missing $HOME/bin/main-menu" >&2
exit 127

