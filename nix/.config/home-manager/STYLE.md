# Coding Style (Nix / Home Manager)

See also: AGENTS.md for a short guide on helpers, activation aggregators, systemd presets, commit message format, and quick `just` commands.

- with pkgs usage
  - Localize `with pkgs;` right next to the list or group where it’s used.
    - Good: `home.packages = with pkgs; [ foo bar ];`
    - Good: `groups = with pkgs; { a = [foo]; b = [bar]; };`
    - Avoid module-wide `with pkgs;` or leaking it across unrelated scopes.
- Line width (~100 chars)
  - Target ~100 characters per line. This keeps diffs readable.
  - Keep end-of-line comments short; if they don't fit, move them above the line.
  - Tip: set an editor ruler at 100 to help keep lines concise.
  - Example:
    - Good: `"reaper" # DAW`
    - Also good (longer note moved above):
      `# Compute DR14 (Pleasurize Music Foundation procedure)`
      `"dr14_tmeter"`
- Comments
  - Prefer concise, recognizable terms (e.g., "DAW", "modular synth").
  - Put long comments above the line they describe (not inline).
  - Avoid repeating obvious context (module name or path) in comments.
- Options
  - Declare feature options centrally (see `modules/features.nix`).
  - Gate per-area configuration via `mkIf` using `features.*` flags.
- Assertions
  - Provide actionable messages when extra inputs or packages are required by a flag.
  - Prefer non-blocking `warnings` via `config.lib.neg.mkWarnIf` for soft migrations and deprecations.
    - Example: `config.lib.neg.mkWarnIf cond "<what to change and how>"`
- Naming
  - Use camelCase for extraSpecialArgs and internal aliases (e.g., `yandexBrowser`, `iosevkaNeg`).
- Structure
  - Factor large package lists into local `groups = { ... }` sets.
  - Use `config.lib.neg.mkEnabledList` to flatten groups based on flags.
    - Prefer over manual chains of `lib.optionals` for readability and consistency.
    - Pattern: `home.packages = config.lib.neg.mkEnabledList config.features.<area> groups;`
    - For nested scopes (e.g., Python withPackages) build `groups` first, then flatten.
  - For systemd user units, prefer `config.lib.neg.systemdUser.mkUnitFromPresets` to set `After`/`Wants`/`WantedBy`/`PartOf` via presets instead of hardcoding targets in each module. Extend with `after`/`wants`/`partOf`/`wantedBy` args only for truly extra dependencies.

- Systemd (user) sockets/paths
  - Apply the same presets helper to `systemd.user.sockets.*` and `systemd.user.paths.*`.
  - Sockets: tie activation to `sockets.target`; add `wantedBy = ["sockets.target"]` explicitly.
    - Example:
      `systemd.user.sockets.my-sock = lib.recursiveUpdate { Unit.Description = "My socket"; Socket.ListenStream = "%t/my.sock"; } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["socketsTarget"]; wantedBy = ["sockets.target"]; });`
  - Paths: usually want `default.target` so the path unit is active in the session.
    - Example:
      `systemd.user.paths.my-path = lib.recursiveUpdate { Unit.Description = "Watch foo"; Path.PathChanged = "%h/.config/foo/config"; } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; });`

- Systemd sugar (timers/sockets)
  - Use `config.lib.neg.systemdUser.mkSimpleTimer` to define small timers; defaults WantedBy to `timers.target` if preset includes `"timers"`.
    - Example:
      `(config.lib.neg.systemdUser.mkSimpleTimer { name = "newsboat-sync"; onCalendar = "hourly"; presets = ["timers"]; timerExtra = { Persistent = true; }; })`
  - Use `config.lib.neg.systemdUser.mkSimpleSocket` to define sockets; defaults WantedBy to `sockets.target` if preset includes `"socketsTarget"`.
    - Example:
      `(config.lib.neg.systemdUser.mkSimpleSocket { name = "my-sock"; listenStream = "%t/my.sock"; presets = ["socketsTarget"]; socketExtra = { SocketMode = "0600"; }; })`

- Commit messages
  - Use bracketed scope: `[scope] subject` (English imperative, concise).
    - Examples: `[activation] add guards for xyz`, `[docs] update OPTIONS.md`.
    - Multi-scope allowed: `[gui/hypr][rules] normalize web classes`.
  - Exceptions allowed: `Merge ...`, `Revert ...`, `fixup!`, `squash!`, `WIP`.
  - A `commit-msg` hook enforces this locally (see modules/dev/git/default.nix).

- XDG file helpers
  - Prefer the pure helpers from `modules/lib/xdg-helpers.nix` (import locally):
    - Config (text/link): `mkXdgText`, `mkXdgSource`
    - Data (text/link): `mkXdgDataText`, `mkXdgDataSource`
    - Cache (text/link): `mkXdgCacheText`, `mkXdgCacheSource`
    - They ensure parent directories are real dirs (not symlinks), remove any
      existing target (symlink, regular file, or directory), then write/link
      the file. This prevents activation failures when a directory exists where
      a file/link is expected.
  - Examples:
    - Config text: `(xdg.mkXdgText "nyxt/init.lisp" "... Lisp ...")`
    - Config source: `(xdg.mkXdgSource "swayimg" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/media/images/swayimg/conf" true))`
    - Data keep: `(xdg.mkXdgDataText "ansible/roles/.keep" "")`
    - Cache keep: `(xdg.mkXdgCacheText "ansible/facts/.keep" "")`
    - Config JSON: `(xdg.mkXdgConfigJson "fastfetch/config.jsonc" { logo = { source = "$XDG_CONFIG_HOME/fastfetch/skull"; }; })`
    - Data JSON: `(xdg.mkXdgDataJson "aria2/state.json" { version = 1; })`
    - Config TOML: `(xdg.mkXdgConfigToml "app/config.toml" { enable = true; nested.option = 1; })`
    - Data TOML: `(xdg.mkXdgDataToml "app/state.toml" { version = 1; list = [1 2 3]; })`
  - Import tip (robust for docs eval): 
    - If JSON/TOML helpers are needed, include `pkgs`:
      - From `modules/dev/...` or `modules/media/...`: `let xdg = import ../../lib/xdg-helpers.nix { inherit lib pkgs; };`
      - From `modules/user/mail/...`: `let xdg = import ../../../lib/xdg-helpers.nix { inherit lib pkgs; };`
    - Otherwise (no TOML/JSON needed), `inherit lib` is enough.

- Merging attrsets
  - Prefer `lib.mkMerge [ a b ... ]` over top-level `//` for combining module fragments.
  - Keep each logical piece in its own attrset within `mkMerge` (e.g., package set, xdg helpers, systemd units).
  - Conditional sugar: use `config.lib.neg.mkWhen` / `config.lib.neg.mkUnless` instead of bare `lib.mkIf` to improve scanability.
    - Example:
      `lib.mkMerge [
         (config.lib.neg.mkWhen config.features.web.enable { programs.aria2.enable = true; })
         (config.lib.neg.mkUnless config.features.gui.enable { xdg.mime.enable = false; })
       ]`

- Runtime directories (first-run safety)
  - Ensure required runtime/state directories exist before services start or files are written.
    - After write: `home.activation.ensureDirs = config.lib.neg.mkEnsureDirsAfterWrite ["$XDG_STATE_HOME/zsh"];`
    - Real config dir: `home.activation.fixFoo = config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/foo";`
    - Maildir trees: `config.lib.neg.mkEnsureMaildirs "$HOME/.local/mail/gmail" ["INBOX" ...]`
  - Use these in addition to xdg helpers when apps require extra runtime dirs (sockets, logs, caches) outside XDG config files.

- Local bin wrappers
  - Prefer `config.lib.neg.mkLocalBin` for `~/.local/bin/<name>` scripts to avoid path conflicts during activation.
    - Example:
      `config.lib.neg.mkLocalBin "rofi" ''#!/usr/bin/env bash
        set -euo pipefail
        exec ${pkgs.rofi-wayland}/bin/rofi "$@"''`
  - This removes any existing path (file/dir/symlink) before linking and marks the target executable.

- Systemd (user) sugar
  - For simple services use `config.lib.neg.systemdUser.mkSimpleService` instead of repeating the same boilerplate.
    - Example:
      `(config.lib.neg.systemdUser.mkSimpleService {
        name = "aria2";
        description = "aria2 download manager";
        execStart = "${pkgs.aria2}/bin/aria2c --conf-path=$XDG_CONFIG_HOME/aria2/aria2.conf";
        presets = ["graphical"];
      })`
  - Under the hood it composes `Unit/Service` and applies `mkUnitFromPresets` for `After/Wants/WantedBy/PartOf`.

- Out-of-store dotfile links
  - For live-editable configs stored in this repo, prefer: `config.lib.neg.mkDotfilesSymlink "path/in/repo" <recursive?>`.
  - Combine with `xdg.mkXdgSource` to get guards + correct placement under XDG.

- Imports (xdg helpers) — convention
  - Use a local binding near the top of a module:
    - `let xdg = import ../../lib/xdg-helpers.nix { inherit lib; }; in lib.mkMerge [ ... ]`
  - Choose `../../` depth according to the module path.
