#!/usr/bin/env bash
set -euo pipefail
if [ -x "$HOME/bin/pl" ]; then
  exec "$HOME/bin/pl" "$@"
fi
sub=${1:-}
case "$sub" in
  cmd)
    shift || true
    case "${1:-}" in
      play-pause|pause|play|next|previous)
        exec playerctl "${1}"
        ;;
    esac
    ;;
  vol)
    shift || true
    case "${1:-}" in
      mute) exec wpctl set-mute @DEFAULT_AUDIO_SINK@ 1 ;;
      unmute) exec wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 ;;
    esac
    ;;
esac
if command -v playerctl >/dev/null 2>&1; then
  exec playerctl "$@"
fi
echo "pl shim: missing $HOME/bin/pl and no usable fallback" >&2
exit 127

