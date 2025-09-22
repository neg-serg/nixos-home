#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/pic-dirs-list" ]; then
  exec "$HOME/bin/pic-dirs-list" "$@"
fi
echo "pic-dirs-list shim: missing $HOME/bin/pic-dirs-list" >&2
exit 127

