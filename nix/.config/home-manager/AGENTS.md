# Agent Guide (Home Manager repo)

This repo is configured for Home Manager + flakes with a small set of helpers to keep modules consistent and activation quiet. This page shows what to use and how to validate changes.

## Helpers & Conventions

- Locations
  - Core helpers: `modules/lib/neg.nix`
  - XDG file helpers: `modules/lib/xdg-helpers.nix`
  - Features/options: `modules/features.nix`
- XDG helpers (preferred)
  - Config text/link: `xdg.mkXdgText`, `xdg.mkXdgSource`
  - Data text/link: `xdg.mkXdgDataText`, `xdg.mkXdgDataSource`
  - Cache text/link: `xdg.mkXdgCacheText`, `xdg.mkXdgCacheSource`
  - Use these instead of ad‑hoc shell to avoid symlink/dir conflicts at activation.
  - JSON convenience: `xdg.mkXdgConfigJson`, `xdg.mkXdgDataJson`
    - Example: `(xdg.mkXdgConfigJson "fastfetch/config.jsonc" { logo = { source = "$XDG_CONFIG_HOME/fastfetch/skull"; }; })`
- Conditional sugar (from `lib.neg`)
  - `mkWhen cond attrs` / `mkUnless cond attrs` — thin wrappers over `lib.mkIf`.
    - Example: `lib.mkMerge [ (config.lib.neg.mkWhen config.features.web.enable { programs.aria2.enable = true; }) ]`
- Activation helpers (from `lib.neg`)
  - `mkEnsureRealDir path` / `mkEnsureRealDirsMany [..]` — ensure real dirs before linkGeneration
  - `mkEnsureAbsent path` / `mkEnsureAbsentMany [..]` — remove conflicting files/dirs pre‑link
  - `mkEnsureDirsAfterWrite [..]` — create runtime dirs after writeBoundary
  - `mkEnsureMaildirs base [boxes..]` — create Maildir trees after writeBoundary
  - Aggregated XDG fixups (new helpers):
    - `mkXdgFixParents { configs = attrNames config.xdg.configFile; datas = attrNames config.xdg.dataFile; caches = attrNames config.xdg.cacheFile; /* optional */ preserveConfigPatterns = [ "some-app/*" ]; }`
      - By default `preserveConfigPatterns = []`. Pass patterns from the specific module only when you need to keep a symlinked parent for part of the tree (e.g., externally managed app config subtree).
    - `mkXdgFixTargets { configs = …; datas = …; caches = …; }`
    - These fixups are wired in `modules/user/xdg/default.nix` as `home.activation.xdgFixParents` and `home.activation.xdgFixTargets`.
  - Common user paths prepared via:
    - `ensureCommonDirs`, `cleanSwayimgWrapper`, `ensureGmailMaildirs`
  - Local bin wrappers (safe ~/.local/bin scripts):
    - `config.lib.neg.mkLocalBin name text` — removes any conflicting path before linking and marks executable.
    - Example: `config.lib.neg.mkLocalBin "rofi" ''#!/usr/bin/env bash
        set -euo pipefail
        exec ${pkgs.rofi-wayland}/bin/rofi "$@"''`
  - Systemd (user) sugar:
    - `config.lib.neg.systemdUser.mkSimpleService { name; description; execStart; presets = [..]; }`
    - Example: `(config.lib.neg.systemdUser.mkSimpleService {
        name = "aria2";
        description = "aria2 download manager";
        execStart = "${pkgs.aria2}/bin/aria2c --conf-path=$XDG_CONFIG_HOME/aria2/aria2.conf";
        presets = ["graphical"];
      })`
  - Soft migrations (warnings):
    - Use `config.lib.neg.mkWarnIf cond "message"` to emit non-fatal guidance.
    - Example (MPD path change):
      `config.lib.neg.mkWarnIf (config.services.mpd.enable or false) "MPD dataDir moved to $XDG_STATE_HOME/mpd; consider migrating from ~/.config/mpd."`

## App Notes

- aria2 (download manager)
  - Keep configuration minimal and XDG-compliant:
    - Use `programs.aria2.settings` with only the essentials:
      - `dir = "${config.xdg.userDirs.download}/aria"` — downloads under XDG Downloads.
      - `enable-rpc = true` — enable RPC for UIs/integrations.
      - `save-session`/`input-file = "$XDG_DATA_HOME/aria2/session"` — persist resume state.
      - `save-session-interval = 1800`.
    - Ensure the session file exists via XDG helper (no ad‑hoc prestart scripts):
      - `(xdg.mkXdgDataText "aria2/session" "")`.
    - Systemd (user) service should be simple:
      - `Service.ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=$XDG_CONFIG_HOME/aria2/aria2.conf"`.
      - Attach preset: `(config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })`.
  - Avoid `ExecStartPre` mkdir/touch logic — aggregated XDG fixups and the data helper make it unnecessary and reduce activation noise.
- systemd (user) presets
  - Always use `config.lib.neg.systemdUser.mkUnitFromPresets { presets = [..]; }`
  - Typical presets:
    - Service in GUI session: `["graphical"]`
    - Wants network online: `["netOnline"]`
    - General user service: `["defaultWanted"]`
    - Timer: `["timers"]`
    - DBus socket ordering: `["dbusSocket"]`
  - Add extras only when needed: `after`, `wants`, `partOf`, `wantedBy`.

## Hyprland notes

- Autoreload is disabled to avoid inotify races during activation (`disable_autoreload = 1`).
- No activation‑time `hyprctl reload`; keep manual reload only (hotkey in `bindings.conf`).
- hy3/Hyprland pins have a compatibility assert in `features.nix`; update the matrix if bumping pins.

## Commit Messages

- Format: `[scope] subject` (English, imperative).
  - Examples: `[activation] reduce noise`, `[features] add flag`, `[gui/hypr] normalize rules`.
  - Multi‑scope allowed: `[xdg][activation] ...`
  - Allowed exceptions: `Merge ...`, `Revert ...`, `fixup!`, `squash!`, `WIP`.
- Keep changes focused and minimal; avoid drive‑by fixes unless requested.

## Language & Comments

- English‑only for code comments, commit messages, and new docs by default.
  - Russian content belongs in dedicated translations only (e.g., `README.ru.md`).
  - Do not add Russian comments inside Nix modules or shell snippets.
- Comment style:
  - Keep comments concise; move long notes above the line they describe.
  - Target ~100 chars width (see STYLE.md) for readability in diffs.
  - Prefer actionable wording over narration.

## Quick Tasks

- Format: `just fmt` (wrapper around `nix fmt`)
- Checks: `just check` (flake checks, docs build)
- Lint only: `just lint` (statix, deadnix, shellcheck, ruff/black if present)
- Switch HM: `just hm-neg` (or `just hm-lite`)

## Guard rails

- Don’t reintroduce Hyprland auto‑reload or activation reload hooks.
- For files under `~/.config` prefer XDG helpers + `mkDotfilesSymlink` instead of manual shell.
- Use feature flags (`features.*`) with `mkIf`; parent flag off implies children default to off.
- Quickshell: `quickshell/.config/quickshell/Settings.json` is ignored; do not add it back.

## Validation

- Local eval: `nix flake check -L` (may build small docs/checks)
- Fast feature view (no build): build `checks.x86_64-linux.hm-eval-neg-retro-off` and inspect JSON
- HM switch (live): `home-manager switch --flake .#neg`

## When updating hy3/Hyprland

- Update pins in `flake.nix` and extend the matrix in `modules/features.nix`:
  - Add `{ hv = "<hyprland version>"; rev = "<hy3 commit>"; }` to `compatible`.
  - Keep Hyprland and hy3 in lock‑step to avoid API breaks.
