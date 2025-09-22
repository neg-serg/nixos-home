#!/bin/sh
# pypr-client: send JSON-RPC to pyprland socket
# Usage: pypr-client '{"cmd": "..."}'
if [ -z "${1:-}" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: pypr-client '{\"cmd\": \"...\"}'" >&2
  exit 1
fi
socat - "UNIX-CONNECT:${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.pyprland.sock" <<< "$@"
