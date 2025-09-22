#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/swayimg-actions.sh" ]; then
  exec "$HOME/bin/swayimg-actions.sh" "$@"
fi
echo "swayimg-actions.sh shim: missing $HOME/bin/swayimg-actions.sh" >&2
exit 127

