#!/usr/bin/env bash
set -euo pipefail
# List windows from Hyprland and select via rofi; focus selected.

clients_json="$(@HYPRCTL@ -j clients 2>/dev/null || true)"
[ -n "$clients_json" ] || exit 0
workspaces_json="$(@HYPRCTL@ -j workspaces 2>/dev/null || true)"
active_json="$(@HYPRCTL@ -j activewindow 2>/dev/null || true)"
[ -n "$active_json" ] || active_json="null"

list=$(jq -nr \
  --argjson clients "$clients_json" \
  --argjson wss "${workspaces_json:-[]}" \
  --argjson active "$active_json" '
    def sanitize: tostring | gsub("[\t\n]"; " ");
    def clip($n): sanitize | if (length > $n) then (.[:($n-1)] + "…") else . end;
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
    # Unwrap possible container objects from hyprctl JSON
    | ($wss | (if (type=="object" and has("workspaces")) then .workspaces else . end)) as $W
    | ($clients | (if (type=="object" and has("clients")) then .clients else . end)) as $C
    # Build id->name map from workspaces
    | ($W | reduce .[] as $w ({}; .[($w.id|tostring)] = (($w.name // ($w.id|tostring))|tostring))) as $wm
    # Collect IDs of special (scratchpad) workspaces to filter out
    | ($W | map(select(.special == true or ((.name // "") | tostring | startswith("special"))) | .id)) as $sids
    | ($active | if (type == "object" and has("address")) then .address else "" end) as $activeAddr
    # Build rows
    | [ $C[]
        # Derive workspace id and name robustly (object or number)
        | ( ((.workspace // null) | type) ) as $wtype
        | (if $wtype == "object" then (.workspace.name // "") else "" end) as $wname
        | (if $wtype == "object" then (.workspace.id // 0) elif $wtype == "number" then .workspace else 0 end) as $wid
        # Exclude scratchpads/special workspaces by multiple heuristics
        | select(($wname | tostring | startswith("special")) | not)
        | select($sids | index($wid) | not)
        | {wid: ($wid|tostring),
           wname: ($wm[($wid|tostring)] // ($wid|tostring)),
           cls: (.class // ""),
           ttl: (.title // ""),
           addr: (.address // "")}
        | select(.addr != $activeAddr)
      ]
    | sort_by(.wid)
    | .[]
    | ((glyph(.cls)) + " [" + (.wname|clip(16)) + "] "
       + (.ttl|clip(52))
       + " • "
       + (.cls|clip(18))
       + "\t"
       + .addr)
  ')
[ -n "$list" ] || exit 0

## Removed group separators to avoid extra lines in the menu

rc=0
set +e
sel=$(rofi -dmenu -matching fuzzy -i -p 'Windows ❯>' \
  -kb-accept-alt 'Alt+Return' -kb-custom-1 'Alt+1' -kb-custom-2 'Alt+2' \
  -columns 6 \
  -theme menu-columns <<< "$list")
rc=$?
set -e
[ "$rc" -ne 0 ] && exit 0
# Ignore separator/header lines (no address column)
if ! printf '%s' "$sel" | grep -q '\t'; then
  exit 0
fi
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
