#!/usr/bin/env bash
set -euo pipefail

# XDG cleanup helper
# - Default mode: remove old cache entries (> RETENTION_DAYS) under $XDG_CACHE_HOME
# - Also purges known-orphan Zotero data under share/state/cache/flatpak
# - Subcommand "delete": remove explicit paths (args or env), guarded to $HOME
#
# Env:
#   RETENTION_DAYS: number of days for age threshold (default 60)
#   DRY_RUN: 1 for report-only, 0 to actually delete (default 0)
#   KEEP_CACHE_NAMES: whitespace-separated basenames to keep in cache (globs ok). Default: "floorp"
#   SKIP_PATHS: whitespace-separated absolute paths to skip entirely
#   TARGETS: whitespace-separated paths for "delete" subcommand
#   TARGETS_FILE: file with newline-separated paths for "delete" subcommand

RETENTION_DAYS="${RETENTION_DAYS:-60}"
DRY_RUN="${DRY_RUN:-0}"
KEEP_CACHE_NAMES="${KEEP_CACHE_NAMES:-floorp}"
SKIP_PATHS="${SKIP_PATHS:-}"

XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME/.local/state"}
VAR_APP="$HOME/.var/app"

log() { printf "[xdg-clean] %s\n" "$*"; }
rm_path() {
  local p="$1"
  if [[ "$DRY_RUN" = "1" ]]; then
    log "DRY: rm -rf -- $p"
  else
    rm -rf -- "$p"
    log "Removed: $p"
  fi
}

du_h() {
  du -sh --apparent-size -- "$@" 2>/dev/null || true
}

log "Retention: ${RETENTION_DAYS}d | Dry-run: ${DRY_RUN}"
log "Keep cache names: ${KEEP_CACHE_NAMES:-<none>}"

usage() {
  cat <<EOF
Usage:
  $0                # Clean caches older than RETENTION_DAYS and purge Zotero remnants
  $0 delete [PATH..]|[--from-file FILE]
                    # Delete explicit paths (under \$HOME only)

Env:
  RETENTION_DAYS (default 60), DRY_RUN (0/1), KEEP_CACHE_NAMES, SKIP_PATHS,
  TARGETS (space-separated paths), TARGETS_FILE (newline-separated paths)
EOF
}

subcmd=${1:-}
if [[ "$subcmd" = "-h" || "$subcmd" = "--help" ]]; then
  usage; exit 0
fi

# 1) Clean caches older than retention at top-level of XDG cache
if [[ -z "$subcmd" && -d "$XDG_CACHE_HOME" ]]; then
  log "Scanning cache: $XDG_CACHE_HOME"
  # list candidates with size
  mapfile -d '' cache_candidates < <(find "$XDG_CACHE_HOME" -mindepth 1 -maxdepth 1 \( -type d -o -type f \) -mtime +"$RETENTION_DAYS" -print0)
  if (( ${#cache_candidates[@]} )); then
    log "Cache candidates (older than ${RETENTION_DAYS}d):"
    du_h "${cache_candidates[@]}" | sed 's/^/  - /'
    for p in "${cache_candidates[@]}"; do
      # Skip explicit paths
      for sp in ${SKIP_PATHS}; do
        if [[ "$p" == "$sp"* ]]; then
          log "SKIP (explicit): $p"
          continue 2
        fi
      done
      # Skip basenames from keep list
      bname="$(basename -- "$p")"
      for pat in ${KEEP_CACHE_NAMES}; do
        if [[ "$bname" == $pat ]]; then
          log "SKIP (keep list): $p"
          continue 2
        fi
      done
      rm_path "$p"
    done
  else
    log "No cache entries older than ${RETENTION_DAYS}d found at top-level."
  fi
fi

# 2) Remove Zotero data if present (explicitly orphaned per user request)
declare -a zotero_paths=(
  "$XDG_DATA_HOME/Zotero"
  "$XDG_DATA_HOME/zotero"
  "$XDG_STATE_HOME/zotero"
  "$XDG_STATE_HOME/Zotero"
  "$XDG_CACHE_HOME/zotero"
  "$XDG_CACHE_HOME/Zotero"
  "$VAR_APP/org.zotero.Zotero"
)

z_found=0
for z in "${zotero_paths[@]}"; do
  if [[ -e "$z" ]]; then
    ((z_found++)) || true
  fi
done

if (( z_found > 0 )); then
  log "Zotero paths found; removing:"
  du_h "${zotero_paths[@]}" | sed 's/^/  - /' || true
  for z in "${zotero_paths[@]}"; do
    [[ -e "$z" ]] && rm_path "$z"
  done
else
  log "No Zotero paths found."
fi

# 3) Subcommand: delete explicit targets (guard to $HOME)
if [[ "$subcmd" = "delete" ]]; then
  shift || true
  declare -a del_targets=()
  if [[ "${1:-}" = "--from-file" ]]; then
    [[ -n "${2:-}" ]] || { echo "--from-file requires a path" >&2; exit 2; }
    mapfile -t from_file < <(grep -v '^\s*$' "${2}")
    del_targets+=("${from_file[@]}")
    shift 2 || true
  fi
  if (( $# > 0 )); then
    del_targets+=("$@")
  fi
  if [[ -n "${TARGETS:-}" ]]; then
    # shellcheck disable=SC2206
    del_targets+=( ${TARGETS} )
  fi
  if [[ -n "${TARGETS_FILE:-}" && -z "${from_file+x}" ]]; then
    mapfile -t from_env_file < <(grep -v '^\s*$' "${TARGETS_FILE}")
    del_targets+=("${from_env_file[@]}")
  fi
  if (( ${#del_targets[@]} == 0 )); then
    log "No delete targets provided."
  else
    log "Explicit delete targets (guarded to \$HOME):"
    for p in "${del_targets[@]}"; do
      # Resolve to absolute path
      ap=$(readlink -f -- "$p" 2>/dev/null || echo "$p")
      case "$ap" in
        "$HOME"/*)
          du_h "$ap" | sed 's/^/  - /' || true
          rm_path "$ap"
          ;;
        *)
          log "SKIP (outside HOME): $ap"
          ;;
      esac
    done
  fi
fi

log "Done."
