# Home Manager (Flakes) — User Environment

Comprehensive, modular Home Manager setup (flake) for a Wayland desktop (Hyprland) and CLI tooling. It uses a few small helpers to keep modules consistent, activation quiet, and user services tidy.

- How to work in this repo: see `AGENTS.md`
- Coding/style rules for modules: `STYLE.md`
- Feature flags (profiles, web/audio/dev, etc.): `modules/features.nix` and `OPTIONS.md`

## Quickstart

Prerequisites
- Nix with flakes enabled: `experimental-features = nix-command flakes`
- Home Manager available via flakes
- Optional: `just` for the commands below (install with `nix profile install nixpkgs#just`)

Clone and switch
- Clone anywhere (example uses `~/.dotfiles`):
  - `git clone --recursive git@github.com:neg-serg/nixos-home.git ~/.dotfiles`
  - `cd ~/.dotfiles`
- Switch profiles:
  - Full: `just hm-neg` (alias for `home-manager switch --flake .#neg`)
  - Lite: `just hm-lite` (alias for `home-manager switch --flake .#neg-lite`)

Bootstrap (new machine)
- If Home Manager isn’t installed as a flake yet:
  - `nix run home-manager/master -- init --switch`
- Then run the Quickstart commands above.

## Everyday Tasks

Formatting, linting, checks
- `just fmt` — treefmt (Nix, shell, Python, etc.)
- `just lint` — statix + deadnix (+ shellcheck/ruff if present)
- `just check` — `nix flake check -L` (evaluations + docs)

Build and status
- `just hm-build` — build activation package only
- `just hm-status` — show failed user units + last 120 journal lines

Feature matrix (fast eval; no build)
- `just show-features` — builds 4 HM eval checks and prints flattened `features.*`
- Filter: `just show-features hm-eval-neg-retro-on hm-eval-lite-retro-off`
- Only true flags: `ONLY_TRUE=1 just show-features`
- Other system: `SYSTEM=aarch64-linux just show-features`

Git hooks (optional)
- `just hooks-enable` — sets `core.hooksPath` to `.githooks` (enforces `[scope] subject` messages)

## Profiles & Features

- Profiles: `features.profile = "full" | "lite"` (default: full)
  - Lite disables most stacks by default (GUI, web, media, dev extras)
- Toggle stacks in `home.nix` under `features.*`, e.g.:
  - `features.gui.enable`, `features.gui.qt.enable`
  - `features.web.enable`, `features.web.default = "floorp" | "firefox" | "librewolf" | "nyxt" | "yandex"`
  - `features.media.audio.core/apps/creation/mpd.enable`
  - `features.emulators.retroarch.full`
  - `features.gpg.enable`
  - `features.excludePkgs = [ "pkgName" ... ]` to drop packages from curated lists

The selected default browser is exposed as `config.lib.neg.web.defaultBrowser` and the full browser table as `config.lib.neg.web.browsers`.

## Secrets (sops‑nix)

- Secrets live under `secrets/` and are referenced from `home.nix` and modules.
- Ensure your `age` key is available; decryption happens on activation. See `.sops.yaml` and `secrets/` for paths.

## Systemd User Services

- Services/timers use presets from `lib.neg.systemdUser.mkUnitFromPresets`:
  - `graphical`, `netOnline`, `defaultWanted`, `timers`, `dbusSocket`, etc.
  - Add extra `after`/`wants`/`partOf`/`wantedBy` only when truly needed.
- For shell snippets, prefer `pkgs.writeShellApplication` with `runtimeInputs`.

## Hyprland & GUI Notes

- Autoreload is intentionally disabled; do not add activation‑time `hyprctl reload`.
- Config is split under `modules/user/gui/hypr/conf` (bindings, rules, workspaces, etc.) and linked to `~/.config/hypr`.
- Rofi wrapper `~/.local/bin/rofi` makes theme lookup robust (relative to config and XDG data).

## Repo Layout

- `flake.nix`, `flake.lock` — flake entry and inputs
- `home.nix` — top‑level HM configuration
- `modules/` — HM modules grouped by domain
- `packages/` — overlays and local packages (`pkgs.neg.*`)
- `secrets/` — sops‑nix data (see `.sops.yaml`)
- `AGENTS.md` — helper API, activation fixups, presets, commit format
- `STYLE.md` — coding conventions for modules
- `OPTIONS.md` — overview of feature flags

## Viewers & Launchers (Examples)

- Images: `swayimg-first` is installed to `~/.local/bin/swayimg` and `~/.local/bin/sx` (Hypr rules route/focus it).
- Rofi: themes are linked into `$XDG_DATA_HOME/rofi/themes`; wrapper enforces `-no-config` unless requested.
- Mozilla: Firefox/LibreWolf/Floorp reuse a common constructor; use `*Extra` fields per‑browser.

## Developer Notes

- Commit subjects must start with `[scope]` (enforced by `.githooks/commit-msg`).
  - Enable hooks: `just hooks-enable` or `git config core.hooksPath .githooks`
- See `AGENTS.md` for activation fixups (XDG parents/targets), `writeShellApplication` usage, and presets.
