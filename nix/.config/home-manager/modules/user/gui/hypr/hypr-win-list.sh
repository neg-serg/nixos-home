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
       + (.cls|sanitize)
       + " - "
       + (.ttl|sanitize)
       + "\t"
       + .addr)
  ')
[ -n "$list" ] || exit 0

# Insert thin separators between workspace groups for readability
list=$(printf '%s\n' "$list" | awk '
  BEGIN{ prev="" }
  {
    if (match($0, /^\[([^]]+)\]/, m)) {
      cur=m[1];
      if (prev!="" && cur!=prev) { print "<span foreground=\"#5c6c7c\">───</span>" }
      prev=cur
    }
    print
  }
')

sel=$(printf '%s\n' "$list" | rofi -dmenu -matching fuzzy -i -markup-rows -p 'Windows ❯>' \
  -mesg 'Enter: open • Alt+Enter: multi • Ctrl+C: cancel' -theme clip) || exit 0
# Ignore separator/header lines (no address column)
if ! printf '%s' "$sel" | grep -q '\t'; then
  exit 0
fi
addr=$(printf '%s' "$sel" | awk -F '\t' '{print $NF}' | sed 's/^ *//')
[ -n "$addr" ] || exit 0

@HYPRCTL@ dispatch focuswindow "address:$addr" >/dev/null 2>&1 || true
@HYPRCTL@ dispatch bringactivetotop >/dev/null 2>&1 || true
