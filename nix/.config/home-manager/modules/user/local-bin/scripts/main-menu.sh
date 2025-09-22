#!/bin/sh
# main-menu: rofi-driven helper actions for music/clipboard/network/etc
# Usage: main-menu
# shellcheck shell=sh

IFS=' 	
'

main_menu='
title_copy
artist_copy
album_copy
path_copy
pipewire_output
alsa_output
translate
termbin
'

generate_menu() {
    blue="<span weight='bold' color='#395573'>"
    count=0
    for item in $main_menu; do
        count=$((count+1))
        printf '%s\n' "$(printf %X "$count"):${blue}⟬</span>${item}${blue}⟭</span>"
    done
}

# Helpers for JSON from rmpc-song
_song_json() { rmpc song 2>/dev/null; } # prints JSON for current song
jq_str()     { jq -r "$1 // empty"; }

title_copy(){
    # Emulate `mpc current`: "Artist - Title" when possible, else Title, else empty
    _song_json | jq -r 'if .metadata.artist and .metadata.title then "\(.metadata.artist) - \(.metadata.title)"
                        else (.metadata.title // .metadata.name // "") end' | wl-copy
}

album_copy(){  _song_json | jq_str '.metadata.album'  | wl-copy; }
artist_copy(){ _song_json | jq_str '.metadata.artist' | wl-copy; }

path_copy(){
    mpd_music_dir="${XDG_MUSIC_DIR:-$HOME/Music}"
    file=$(_song_json | jq_str '.file')
    [ -n "$file" ] && printf '%s/%s\n' "$mpd_music_dir" "$file" | wl-copy
}

pipewire_output(){
    rmpc-pause
    rmpc-enableoutput PipeWire
    rmpc-disableoutput "$dac_name"
    rmpc-play
}

alsa_output(){
    timeout="5s"
    rmpc-pause
    rmpc-enableoutput "$dac_name"
    rmpc-disableoutput PipeWire
    rmpc-play
    sleep "$timeout"
    rmpc-play
}

translate(){
    text="$(wl-paste)"
    translate="$(trans -brief :ru "$text")"
    notify-send -t $((${#text} * 150)) "$translate"
    play-sound "cyclist.ogg"
}

termbin(){
    url=$(wl-paste | nc termbin.com 9999)
    echo "$url" | wl-copy
    notify-send "$url copied to clipboard"
    play-sound "direct.ogg"
}

handler() {
    while IFS= read -r line; do
        sel_item=$(printf '%s' "$line" \
          | sed -e 's/^[^:]*://' -e 's/<[^>]*>//g' -e 's/.*⟬//' -e 's/⟭.*//')
        if [ -n "$sel_item" ]; then
            for t in $main_menu; do
                if [ "$sel_item" = "$t" ]; then
                    "$t"
                    break
                fi
            done
        fi
    done
}

dac_name='RME ADI-2/4 PRO SE'
set -- -auto-select -markup-rows -b -lines 1 -theme neg -dmenu -p '❯>'
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  sed -n '2,2p' "$0" | sed 's/^# \{0,1\}//'; exit 0
fi
# no eval; pass options directly
generate_menu | rofi "$@" | handler
