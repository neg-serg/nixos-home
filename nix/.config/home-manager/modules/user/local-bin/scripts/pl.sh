#!/usr/bin/env zsh
# pl: fuzzy-pick and play videos (fzf/rofi -> mpv + vid-info)
# Usage:
#   pl [rofi|video|1st_level] [DIR]
#   pl cmd <playerctl-args>
#   pl vol {mute|unmute}


IFS=$'\n\t'

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

need() { command -v "$1" >/dev/null 2>&1 || { print -u2 "pl: missing $1"; :; }; }

mp() {
    local -a files
    files=("$@")
    if [[ -x ~/bin/vid-info ]]; then
        # Info for directories
        for f in "$@"; do
            if [[ -d "$f" ]]; then
                { find -- "$f" -maxdepth 1 -type f -print0 | xargs -0 -n10 -P 10 ~/bin/vid-info; } &
            fi
        done
        # Info for files
        {
            local -a only_files
            only_files=()
            for f in "$@"; do
                [[ -f "$f" ]] && only_files+=("$f")
            done
            if (( ${#only_files[@]} )); then
                printf '%s\0' "${only_files[@]}" | xargs -0 -n10 -P 10 ~/bin/vid-info
            fi
        } &
    fi
    mkdir -p -- "$HOME/tmp"
    local ipc="${XDG_CONFIG_HOME:-$HOME/.config}/mpv/socket"
    mpv --input-ipc-server="$ipc" --vo=gpu -- "$@" > "$HOME/tmp/mpv.log" 2>&1
}

find_candidates() {
    # find_candidates <dir> [maxdepth]
    local dir="$1"; local maxd="${2:-}"
    if command -v fd >/dev/null 2>&1; then
        local -a cmd
        cmd=(fd -t f --hidden --follow -E .git -E node_modules -E '*.srt' . "$dir")
        [[ -n "$maxd" ]] && cmd=(fd -t f --hidden --follow -E .git -E node_modules -E '*.srt' -d "$maxd" . "$dir")
        "${cmd[@]}"
    else
        local -a cmd
        cmd=(rg --files --hidden --follow -g '!{.git,node_modules}/*' -g '!*.srt' "$dir")
        [[ -n "$maxd" ]] && cmd=(rg --files --hidden --follow -g '!{.git,node_modules}/*' -g '!*.srt' --max-depth "$maxd" "$dir")
        "${cmd[@]}"
    fi
}

pl_fzf() {
    local dir="${1:-${XDG_VIDEOS_DIR:-$HOME/vid}}"
    dir="${~dir}"
    need fzf
    local sel
    sel=$(find_candidates "$dir" "$2" | fzf --multi --prompt '⟬vid⟭ ❯>' || true)
    [[ -z "${sel:-}" ]] && return 0
    print -r -- "$sel" | wl-copy || true
    # Build absolute paths
    local -a targets
    targets=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ "$line" = /* ]]; then
            targets+=("$line")
        else
            targets+=("$dir/$line")
        fi
    done <<< "$sel"
    (( ${#targets[@]} )) && mp "${targets[@]}"
}

pl_rofi() {
    local dir="${1:-${XDG_VIDEOS_DIR:-$HOME/vid}}"
    dir="${~dir}"
    local maxd="${2:-}"
    local list sel
    list=$(find_candidates "$dir" "$maxd")
    if [[ -z "$list" ]]; then
        return 0
    fi
    if (( ${#${(f)list}[@]} > 1 )); then
        sel=$(print -r -- "$list" | rofi -theme clip -p '⟬vid⟭ ❯>' -i -dmenu)
    else
        sel="$list"
    fi
    [[ -z "${sel:-}" ]] && return 0
    print -r -- "$sel" | wl-copy || true
    # Absolute path
    if [[ "$sel" != /* ]]; then
        sel="$dir/$sel"
    fi
    mp "$sel"
}

main() {
    local set_maxdepth=false
    local maxd=""
    local mode="fzf"
    local dir=""
    if [[ "${1:-}" == "rofi" ]]; then
        mode="rofi"; shift
    fi
    if [[ "${1:-}" == "video" ]]; then
        # Keep legacy rofi file-browser path
        shift
        rofi -modi file-browser-extended -show file-browser-extended \
            -file-browser-dir "~/vid/new" -file-browser-depth 1 \
            -file-browser-open-multi-key "kb-accept-alt" \
            -file-browser-open-custom-key "kb-custom-11" \
            -file-browser-hide-hidden-symbol "" \
            -file-browser-path-sep "/" -theme clip \
            -file-browser-cmd 'mpv --input-ipc-server=/tmp/mpvsocket --vo=gpu'
        return
    fi
    if [[ "${1:-}" == "1st_level" ]]; then
        set_maxdepth=true; shift
    fi
    dir="${1:-}"
    if [[ "$set_maxdepth" == true ]]; then maxd=1; fi
    if [[ "$mode" == rofi ]]; then
        pl_rofi "${dir:-}" "$maxd"
    else
        pl_fzf "${dir:-}" "$maxd"
    fi
}

case "${1:-}" in
    -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    cmd) shift; playerctl "$@" ;;
    vol)
        case "${2:-}" in
            mute) vset 0.0 || amixer -q set Master 0 mute ;;
            unmute) vset 1.0 || amixer -q set Master 65536 unmute ;;
        esac ;;
    *) main "$@" ;;
esac
