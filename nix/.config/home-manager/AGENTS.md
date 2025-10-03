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
  - TOML convenience: `xdg.mkXdgConfigToml`, `xdg.mkXdgDataToml`
    - Import with pkgs: `let xdg = import ../../lib/xdg-helpers.nix { inherit lib pkgs; };`
    - Example: `(xdg.mkXdgConfigToml "myapp/config.toml" { core.enable = true; paths = ["a" "b"]; })`
- Conditional sugar (from `lib.neg`)
  - `mkWhen cond attrs` / `mkUnless cond attrs` — thin wrappers over `lib.mkIf`.
    - Example: `lib.mkMerge [ (config.lib.neg.mkWhen config.features.web.enable { programs.aria2.enable = true; }) ]`
- Activation helpers (from `lib.neg`)
  - `mkEnsureRealDir path` / `mkEnsureRealDirsMany [..]` — ensure real dirs before linkGeneration
  - `mkEnsureAbsent path` / `mkEnsureAbsentMany [..]` — remove conflicting files/dirs pre‑link
  - `mkEnsureDirsAfterWrite [..]` — create runtime dirs after writeBoundary
  - `mkEnsureMaildirs base [boxes..]` — create Maildir trees after writeBoundary
  - Aggregated XDG fixups were removed to reduce activation noise.
    - Prefer per‑file `force = true` on `home.file` or `xdg.(config|data|cache)File` entries if you need to overwrite a conflicting path.
    - Keep modules simple: declare targets via `xdg.mkXdg*` helpers and rely on Home Manager to manage links.
  - Common user paths prepared via:
    - `ensureCommonDirs`, `cleanSwayimgWrapper`, `ensureGmailMaildirs`
  - Local bin wrappers (safe ~/.local/bin scripts):
    - `config.lib.neg.mkLocalBin name text` — removes any conflicting path before linking and marks executable.
    - Example: `config.lib.neg.mkLocalBin "rofi" ''#!/usr/bin/env bash
        set -euo pipefail
        exec ${pkgs.rofi-wayland}/bin/rofi "$@"''`
- Systemd (user) sugar:
    - In this repository, use the stable pattern: `lib.mkMerge + config.lib.neg.systemdUser.mkUnitFromPresets`.
    - The "simple" helpers (`mkSimpleService`, `mkSimpleTimer`, `mkSimpleSocket`) are available but can trigger HM‑eval recursion in some contexts. Default policy: do not use them in modules; instead assemble units as below.
    - Example (service):
      ```nix
      systemd.user.services.my-service = lib.mkMerge [
        {
          Unit = { Description = "My Service"; };
          Service.ExecStart = "${pkgs.foo}/bin/foo --flag";
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; })
      ];
      ```
    - Example (timer):
      ```nix
      systemd.user.timers.my-timer = lib.mkMerge [
        {
          Unit.Description = "My Timer";
          Timer = { OnBootSec = "2m"; OnUnitActiveSec = "10m"; Unit = "my-timer.service"; };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["timers"]; })
      ];
      ```

- Rofi wrapper (launcher)
  - A local wrapper is installed to `~/.local/bin/rofi` to provide safe defaults and consistent UX:
    - Adds `-no-config` unless the caller explicitly passes `-config`/`-no-config`.
    - Ensures Ctrl+C cancels (`-kb-cancel "Control+c,Escape"`) and frees it from the default copy binding (`-kb-secondary-copy ""`).
    - Resolves themes passed via `-theme <name|name.rasi>` relative to `$XDG_DATA_HOME/rofi/themes` or `$XDG_CONFIG_HOME/rofi`.
    - Computes offsets for top bars via Quickshell/Hyprland metadata when not provided.
  - Guidance:
    - Keep rofi invocations plain (e.g., `rofi -dmenu ... -theme menu`). Avoid repeating `-no-config`/`-kb-*` in configs.
    - If you must override keys for a particular call, pass your own `-kb-*` flags — the wrapper will not inject defaults twice.

- Editor shim (`v`)
  - A tiny wrapper `~/.local/bin/v` launches Neovim (`nvim`). Prefer `v` in bindings/commands where a short editor command is desirable.
  - Git difftool/mergetool examples in this repo now use `nvim` directly; legacy `~/bin/v` is no longer referenced.
- Soft migrations (warnings):
  - Prefer `{ warnings = lib.optional cond "message"; }` to emit non‑fatal guidance.
  - Avoid referencing `config.lib.neg` in warnings to keep option evaluation acyclic.
  - Example (MPD path change):
    `{ warnings = lib.optional (config.services.mpd.enable or false) "MPD dataDir moved to $XDG_STATE_HOME/mpd; consider migrating from ~/.config/mpd."; }`
  - Template and tips:
    - Keep conditions cheap to evaluate (avoid invoking helpers from `config.lib.neg`).
    - Phrase messages with clear destination and rationale (XDG compliance, less activation noise, etc.).
    - Example:
      ``
      (let
        old = "${config.home.homeDirectory}/.config/app";
        target = "${config.xdg.stateHome}/app";
        needsMigration = (cfg.enable or false) && ((cfg.dataDir or old) == old);
      in {
        warnings = lib.optional needsMigration "App dataDir uses ~/.config/app. Migrate to $XDG_STATE_HOME/app (" + target + ") for XDG compliance.";
      })
      ```

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
  - Avoid `ExecStartPre` mkdir/touch logic — prefer XDG helpers and per‑file `force = true`; reduces activation noise.

- rofi (launcher)
  - Use the local wrapper `rofi` from `~/.local/bin` (PATH is set so it takes precedence).
  - Do not pass `-kb-cancel` or `-no-config` unless you need custom behavior; the wrapper ensures sane defaults and Ctrl+C cancellation.
  - Themes live under `$XDG_CONFIG_HOME/rofi` and `$XDG_DATA_HOME/rofi/themes`; `-theme menu` works out of the box.
- Floorp (browser chrome tweaks)
  - To live-inspect toolbar nodes (bottom nav, urlbar chips, etc.) open `chrome://browser/content/browser.xhtml` in a new tab; it renders the browser chrome inside regular content so standard devtools work.
  - With that page focused press `Ctrl+Shift+I` (or use *Tools → Browser Tools → Toggle Tools*) to launch the inspector and probe selectors before baking them into `userChrome.css`.
  - Close the tab when finished so the embedded chrome document is not left running in the background.
- systemd (user) presets
  - Always use `config.lib.neg.systemdUser.mkUnitFromPresets { presets = [..]; }` (recommended)
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
- For files under `~/.config` prefer XDG helpers + `config.lib.file.mkOutOfStoreSymlink` instead of ad‑hoc shell.
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
