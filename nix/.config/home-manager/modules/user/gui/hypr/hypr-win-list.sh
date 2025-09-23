#!/usr/bin/env bash
set -euo pipefail
# List windows from Hyprland and select via rofi; focus selected.

clients_json="$(@HYPRCTL@ -j clients 2>/dev/null || true)"
[ -n "$clients_json" ] || exit 0
workspaces_json="$(@HYPRCTL@ -j workspaces 2>/dev/null || true)"

list=$(jq -nr \
  --argjson clients "$clients_json" \
  --argjson wss "${workspaces_json:-[]}" '
    def sanitize: tostring | gsub("[\t\n]"; " ");
    # Build id->name map
    def wmap:
      reduce $wss[] as $w ({}; .[($w.id|tostring)] = (($w.name // ($w.id|tostring))|tostring));
    # Map class to glyph (fallback to generic window)
    def glyph(c):
      if (c|test("^(firefox|floorp)$")) then ""
      elif (c|test("kitty|term|alacritty|foot")) then ""
      elif (c|test("mpv")) then ""
      elif (c|test("zathura|org\\.pwmt\\.zathura")) then ""
      elif (c|test("steam|Steam")) then ""
      elif (c|test("discord|Discord")) then ""
      elif (c|test("obs|obsidian|Obsidian|OBS")) then ""
      elif (c|test("swayimg|sxiv|nsxiv")) then ""
      else "" end;
    . as $in
    | ($in | wmap) as $wm
    | [ $clients[]
        | select(.mapped==true)
        | {wid: (.workspace.id|tostring),
           wname: ($wm[.workspace.id|tostring] // (.workspace.id|tostring)),
           cls: (.class // ""),
           ttl: (.title // ""),
           addr: (.address // "")}
      ]
    | sort_by(.wid)
    | .[]
    | ("[" + (.wname|sanitize) + "] "
       + (glyph(.cls)) + " "
       + (.cls|sanitize) + " - "
       + (.ttl|sanitize)
       + "\t"
       + .addr)
  ')
[ -n "$list" ] || exit 0

## Removed group separators to avoid extra lines in the menu

sel=$(printf '%s\n' "$list" | rofi -dmenu -matching fuzzy -i -p 'Windows ❯>' \
  -kb-accept-alt 'Alt+Return' -kb-custom-1 'Alt+1' -kb-custom-2 'Alt+2' \
  -mesg 'Enter: focus • Alt+1: copy title • Ctrl+C: cancel' -theme clip) || exit 0
# Ignore separator/header lines (no address column)
if ! printf '%s' "$sel" | grep -q '\t'; then
  exit 0
fi
rc=$?
# Extract raw address from right column
addr=$(printf '%s' "$sel" | awk -F '\t' '{print $NF}' | sed 's/^ *//')
[ -n "$addr" ] || exit 0

if [ "$rc" = 10 ]; then
  # Copy window title (strip workspace and class)
  printf '%s' "$sel" \
    | awk -F '\t' '{print $1}' \
    | sed -E 's/^\[[^]]+\] *//; s/^[^ ]+ - *//' \
    | wl-copy
  exit 0
fi
@HYPRCTL@ dispatch focuswindow "address:$addr" >/dev/null 2>&1 || true
@HYPRCTL@ dispatch bringactivetotop >/dev/null 2>&1 || true
