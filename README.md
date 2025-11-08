# Home Manager (Flakes) — Comprehensive Guide

This repository provides a modular Home Manager configuration for a Wayland desktop (Hyprland) and a curated CLI toolset. It is a self‑contained flake with helpers to keep activation quiet, services consistent, and configuration safe under XDG.

Useful references:
- How to work in this repo (helpers, presets): `AGENTS.md`
- Coding style for modules: `STYLE.md`
- Feature flags and defaults: `modules/features.nix`, overview in `OPTIONS.md`

--------------------------------------------------------------------------------

## 1) Prerequisites

1. Install Nix and enable flakes
   - Add to `/etc/nix/nix.conf` (system‑wide) or set per‑command:
     - `experimental-features = nix-command flakes`
   - Verify: `nix --version` and `nix flake --help`

2. Install (or run) Home Manager via flakes
   - One‑shot init (if HM isn’t set up yet):
     - `nix run home-manager/master -- init --switch`

3. Optional but recommended: Just
   - `nix profile install nixpkgs#just`

--------------------------------------------------------------------------------

## 2) Clone & Switch Profiles

Clone
- GitHub via SSH (recommended):
  - `git clone --recursive git@github.com:neg-serg/nixos-home.git ~/.dotfiles`
- GitHub via HTTPS:
  - `git clone --recursive https://github.com/neg-serg/nixos-home ~/.dotfiles`
- Enter the repo: `cd ~/.dotfiles`

Switch (Home Manager)
- Full profile: `just hm-neg` (same as `home-manager switch --flake .#neg`)
- Lite profile: `just hm-lite` (same as `home-manager switch --flake .#neg-lite`)

Build without switching
- `just hm-build` — useful for CI or sanity checks

--------------------------------------------------------------------------------

## 3) Caches & Flake Config

The flake declares `nixConfig` (caches + keys) and Home Manager is set to accept it:
- In `home.nix`: `nix.settings.accept-flake-config = true;`
- Caches include `nix-community`, `hyprland`, and more (see `flake.nix`).

If your system ignores flake‑embedded configs, add them to `/etc/nix/nix.conf`.
Check effective config: `nix show-config`.

--------------------------------------------------------------------------------

## 4) Profiles & Feature Flags

Profiles
- `features.profile = "full" | "lite"` (default: full)
  - Lite disables most stacks (GUI, web, media, extra dev) by default.

Common flags (set in `home.nix` or via module overlays)
- GUI: `features.gui.enable`, `features.gui.qt.enable`
- Web: `features.web.enable`, `features.web.default = "floorp" | "firefox" | "librewolf" | "nyxt" | "yandex"`

Optional: Nyxt QtWebEngine provider
- To prefer Nyxt with the QtWebEngine (Blink) backend, provide a flake input exposing a suitable package and it will be auto‑picked if present.
- Expected attribute names (first match wins): `nyxt-qtwebengine`, `nyxt-qt`, `nyxt4`, `nyxt` under `packages.<system>`.
- Example flake input (disabled by default):
  - In `flake.nix` inputs, add (uncomment and point to a real provider):
    `# nyxtQt = { url = "github:<owner>/<repo>"; };`
  - The module will pick it up via `nyxt4` special arg.
- Audio: `features.media.audio.core/apps/creation/mpd.enable`
- Emulators: `features.emulators.retroarch.full`
- GPG: `features.gpg.enable`
- Exclude packages (by pname) from curated lists: `features.excludePkgs = [ "name" ... ]`
- Torrents: `features.torrent.enable` (Transmission/tools/service)

Inspect flags without building
- `just show-features` — prints flattened `features.*` for both profiles and RetroArch toggles
- Only enabled keys: `ONLY_TRUE=1 just show-features`
- Filter checks: `just show-features hm-eval-neg-retro-on`

--------------------------------------------------------------------------------

## 5) Everyday Commands

Formatting, linting, checks
- `just fmt` — run treefmt across the repo
- `just lint` — statix + deadnix (+ shellcheck/ruff if present)
- `just check` — `nix flake check -L` (validates HM evals and docs)

Status & logs
- `just hm-status` —
  - `systemctl --user --failed`
  - `journalctl --user -b -n 120 --no-pager`

Git hooks (optional)
- `just hooks-enable` — setup `.githooks` (enforces `[scope] subject` commit messages)

--------------------------------------------------------------------------------

## 6) Secrets (sops‑nix)

Layout
- Secrets live in `secrets/`, referenced from `home.nix` and modules.
- `.sops.yaml` defines keys and file rules.

Age keys
- Ensure your age key is present (e.g., `~/.config/sops/age/keys.txt`).
- On activation, sops‑nix decrypts secrets and symlinks them into HM’s build output.

Typical uses
- Nix settings `netrc-file` for GitHub access
- Cachix token via a sops file

--------------------------------------------------------------------------------

## 7) Systemd (User) Services

Presets
- Use `config.lib.neg.systemdUser.mkUnitFromPresets` to attach the right targets:
  - `graphical`, `netOnline`, `defaultWanted`, `timers`, `dbusSocket`, `socketsTarget`
- Extend with `after` / `wants` / `partOf` / `wantedBy` only if needed.

Managing services
- Start/stop/status: `systemctl --user start|stop|status <name>`
- Logs: `journalctl --user -u <name> -n 100 -f`

Implementation tips
- Use `pkgs.writeShellApplication` for ExecStartPre/ExecStart wrappers.
- Prefer `lib.getExe` / `lib.getExe'` over hard‑coding `${pkgs.foo}/bin/foo`.

--------------------------------------------------------------------------------

## 8) Hyprland & GUI

Hyprland
- Autoreload is disabled; don’t trigger `hyprctl reload` during activation.
- Config split under `modules/user/gui/hypr/conf` (bindings, rules, workspaces, autostart, etc.).
- `hy3` plugin and Hyprland are pinned; compatibility is asserted in `modules/features.nix`.

Rofi
- Wrapper `~/.local/bin/rofi` ensures theme discovery and safe defaults (`-no-config` unless requested).
- Themes are linked into `$XDG_DATA_HOME/rofi/themes`.
 - Auto-accept is enabled by default (`-auto-select`). Disable per call with `-no-auto-select` if needed.

Images
- `swayimg-first` wrapper is installed to `~/.local/bin/swayimg` and `~/.local/bin/sx` for convenience.

Keyboard Layout Indicator (Quickshell + Hyprland)
- Instant UI update: the bar indicator updates immediately from Hyprland’s `keyboard-layout` payload (no timers/debounce).
- Main device preference: the module identifies the `main: true` keyboard at init and prefers its events, ignoring pseudo devices (power‑button, video‑bus, virtual keyboards).
- Conditional confirmation: if an event comes from a non‑main device, it performs a single `hyprctl -j devices` snapshot to confirm/correct the label. No per‑event snapshots to avoid latency.
- Click behavior: toggles layout using `hyprctl switchxkblayout current next` (no shell involved) for speed.
- Recommended Hyprland binding: `bind = $M4, S, switchxkblayout, current, next` (dispatcher syntax with comma‑separated args).
- More details: quickshell/.config/quickshell/Docs/Config.md

Floorp navbar (top vs bottom)
- Floorp keeps the navigation toolbar at the top. The bottom‑navbar CSS hacks (MrOtherGuy style)
  are disabled for Floorp because they are brittle with Floorp’s own theme changes and can
  misplace panels/urlbar popups. Minimal, safe tweaks remain (findbar polish, compact tabs).
- Inspect/verify selectors via `chrome://browser/content/browser.xhtml` (open devtools there).
- If you still want a bottom navbar, change `bottomNavbar = false` to `true` for Floorp in
  `modules/user/web/floorp.nix` and maintain the overrides locally.

--------------------------------------------------------------------------------

## 9) XDG & Activation Safety

XDG helpers
- Use `modules/lib/xdg-helpers.nix` (`mkXdgText`, `mkXdgSource`, `mkXdgData*`, `mkXdgCache*`).
- If a path already exists, set `force = true` on that entry to overwrite; избегайте ad‑hoc rm/mkdir в ExecStartPre.

Activation helpers
- `mkEnsureRealDir[s]`, `mkEnsureAbsent[Many]`, `mkEnsureDirsAfterWrite`, `mkEnsureMaildirs`.

--------------------------------------------------------------------------------

## 10) Updating Inputs

General
- Update all inputs: `nix flake update`
- Or a single input: `nix flake lock --update-input <name>`

Hyprland/hy3 compatibility
- If you bump pins, also extend the compatibility matrix in `modules/features.nix`.
- The assert will fail early with a helpful message if pins are incompatible.

--------------------------------------------------------------------------------

## 11) Troubleshooting

Activation/eval errors
- `just hm-status` to check failed units and recent logs
- Rebuild without switching: `just hm-build`

Common issues
- Services failing on non‑NixOS (missing system paths) — units include guards like `ConditionPathExists`; report if you hit any gaps.
- Stale symlinks or unexpected files under XDG paths — используйте `force = true` на конкретных файлах или удалите конфликт вручную один раз.
- Editor/terminal not launching — defaults come from `features.web.default` and XDG choices; verify via `show-features` and `xdg-mime query`.

Cleanup helpers
- `just clean-caches` — removes local caches (zsh/nu caches, pycache, etc.) within the repo tree and some common XDG paths.

--------------------------------------------------------------------------------

## 12) Repo Layout

- `flake.nix`, `flake.lock` — flake entry and inputs
- `home.nix` — top‑level Home Manager configuration
- `modules/` — HM modules (CLI, dev, media, user, etc.)
- `packages/` — overlays and local packages (`pkgs.neg.*` namespace)
- `secrets/` — sops‑nix secrets (see `.sops.yaml`)
- Docs:
  - `AGENTS.md` — helper APIs, activation helpers, presets, commit conventions
  - `STYLE.md` — coding style and patterns used in modules
  - `OPTIONS.md` — feature flags overview and profile deltas

--------------------------------------------------------------------------------

## 13) Contribution Notes

- Commit messages: `[scope] subject` (English, imperative). Examples:
  - `[activation] reduce noise`
  - `[features] add torrent flag`
  - `[paths] use lib.getExe for binaries`
- Enable hooks: `just hooks-enable` or `git config core.hooksPath .githooks`
- Keep changes focused; prefer small, reviewable patches.
