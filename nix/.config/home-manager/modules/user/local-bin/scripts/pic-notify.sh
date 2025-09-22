#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/pic-notify" ]; then
  exec "$HOME/bin/pic-notify" "$@"
fi
# Dunst script compatibility: ignore silently if missing
exit 0

