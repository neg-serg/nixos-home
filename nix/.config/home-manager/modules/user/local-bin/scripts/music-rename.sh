#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/music-rename" ]; then
  exec "$HOME/bin/music-rename" "$@"
fi
echo "music-rename shim: missing $HOME/bin/music-rename" >&2
exit 127

