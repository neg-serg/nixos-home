#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/unlock" ]; then
  exec "$HOME/bin/unlock" "$@"
fi
echo "unlock shim: missing $HOME/bin/unlock" >&2
exit 127

