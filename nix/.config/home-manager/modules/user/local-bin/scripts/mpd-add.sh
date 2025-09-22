#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/mpd-add" ]; then
  exec "$HOME/bin/mpd-add" "$@"
fi
echo "mpd-add shim: missing $HOME/bin/mpd-add" >&2
exit 127

