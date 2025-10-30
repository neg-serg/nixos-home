#!/usr/bin/env bash
set -euo pipefail

# XDG usage report (read-only)
# Lists largest top-level entries in XDG data/state/flatpak roots
# and shows age (days) based on entry mtime. Intended for manual review.
#
# Env:
#   RETENTION_DAYS: threshold for "old" (default 60)
#   TOP_N: show top N entries by size (default 30)
#   SKIP_BASENAMES: whitespace list of basenames to skip (default: floorp)
#   SKIP_PATHS: whitespace list of absolute paths to skip
#   ROOTS: space-separated list of roots to scan (default: $XDG_DATA_HOME $XDG_STATE_HOME ~/.var/app)

RETENTION_DAYS="${RETENTION_DAYS:-60}"
TOP_N="${TOP_N:-30}"
SKIP_BASENAMES="${SKIP_BASENAMES:-floorp}"
SKIP_PATHS="${SKIP_PATHS:-}"

XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME/.local/state"}
VAR_APP="$HOME/.var/app"

ROOTS="${ROOTS:-$XDG_DATA_HOME $XDG_STATE_HOME $VAR_APP}"

log() { printf "[xdg-report] %s\n" "$*"; }

if ! command -v stat >/dev/null 2>&1; then
  echo "stat is required" >&2
  exit 1
fi

printf "[xdg-report] Retention: %sd | Top: %s | Roots: %s\n" "$RETENTION_DAYS" "$TOP_N" "$ROOTS"
printf "[xdg-report] Skip basenames: %s\n" "${SKIP_BASENAMES:-<none>}"

tmp_report="$(mktemp -t xdg-report.XXXXXX)"
trap 'rm -f "$tmp_report"' EXIT

now_s=$(date +%s)

scan_root() {
  local root="$1"
  [[ -d "$root" ]] || return 0
  log "Scanning: $root"
  while IFS= read -r -d '' p; do
    # Skip explicit paths
    for sp in ${SKIP_PATHS}; do
      [[ "$p" == "$sp"* ]] && continue 2
    done
    # Skip by basename
    bname="$(basename -- "$p")"
    for sb in ${SKIP_BASENAMES}; do
      [[ "$bname" == $sb ]] && continue 2
    done
    # Size and age
    size_b=$(du -sb --apparent-size -- "$p" 2>/dev/null | cut -f1 || echo 0)
    size_h=$(du -sh --apparent-size -- "$p" 2>/dev/null | cut -f1 || echo 0)
    mtime=$(stat -c %Y -- "$p" 2>/dev/null || echo 0)
    age_d=$(( (now_s - mtime) / 86400 ))
    # Only include if older than retention
    if (( age_d >= RETENTION_DAYS )); then
      printf "%s|%s|%s|%s|%s\n" "$size_b" "$size_h" "$age_d" "$root" "$p" >>"$tmp_report"
    fi
  done < <(find "$root" -mindepth 1 -maxdepth 1 \( -type d -o -type f \) -print0)
}

for r in $ROOTS; do
  scan_root "$r"
done

if [[ ! -s "$tmp_report" ]]; then
  log "No candidates older than ${RETENTION_DAYS}d."
  exit 0
fi

printf "size_bytes | size | age_days | root | path\n"
LC_ALL=C sort -t '|' -k1,1nr "$tmp_report" \
  | awk -F'|' 'NF>=5' \
  | head -n "$TOP_N" \
  | awk -F'|' '{printf "%10s | %6s | %8s | %s | %s\n", $1, $2, $3, $4, $5}'
