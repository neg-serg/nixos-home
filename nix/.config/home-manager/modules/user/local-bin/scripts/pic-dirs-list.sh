#!/bin/sh
# Usage: pic-dirs-list

IFS=' 	
'
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  sed -n '2,2p' "$0" | sed 's/^# \{0,1\}//'; exit 0
fi
# pic-dirs-list: index $XDG_PICTURES_DIR dirs with fasd on changes (writes to swayimg DB)
[ -n "${XDG_PICTURES_DIR:-}" ] || exit 0
command -v inotifywait >/dev/null 2>&1 || exit 0
inotifywait -q -m -e DELETE,ISDIR -e CREATE,ISDIR "$XDG_PICTURES_DIR"/ | while read -r _; do
  find "$XDG_PICTURES_DIR" -maxdepth 3 \
    -not -path "$XDG_PICTURES_DIR/.git/*" \
    -not -path "$XDG_PICTURES_DIR/.git" -type d -print0 \
    | _FASD_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/swayimg/data" xargs -0 fasd -A || true
done
