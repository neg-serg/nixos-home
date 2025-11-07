{
  lib,
  config,
  pkgs,
  xdg,
  hy3, # flake input (passed via mkHMArgs) to locate hy3 plugin path
  inputs, # expose flake inputs (hyprland) to align runtime with hy3
  raiseProvider ? null,
  ...
}:
with lib; let
  hyprWinList = pkgs.writeShellApplication {
    name = "hypr-win-list";
    runtimeInputs = [
      pkgs.python3
      pkgs.wl-clipboard
    ];
    text = let
      tpl = builtins.readFile ../hypr/hypr-win-list.py;
    in ''
                   exec python3 <<'PY'
      ${tpl}
      PY
    '';
  };
  coreFiles = [
    "init.conf"
    "vars.conf"
    "classes.conf"
    "rules.conf"
    "bindings.conf"
    "autostart.conf"
  ];
  mkHyprSource = rel:
    xdg.mkXdgSource ("hypr/" + rel) {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/hypr/conf/${rel}";
      recursive = false;
      # Ensure repo-managed Hypr files replace any existing files
      force = true;
    };
in
  mkIf config.features.gui.enable (lib.mkMerge [
    # Local helper: safe Hyprland reload that ensures Quickshell is started if absent
    (let
      mkLocalBin = import ../../../../packages/lib/local-bin.nix {inherit lib;};
    in
      mkLocalBin "hypr-reload" ''#!/usr/bin/env bash
        set -euo pipefail
        # Reload Hyprland config (ignore failure to avoid spurious errors)
        hyprctl reload >/dev/null 2>&1 || true
        # Give Hypr a brief moment to settle before (re)starting quickshell
        sleep 0.15
        # Start quickshell only if not already active; 'start' is idempotent.
        systemctl --user start quickshell.service >/dev/null 2>&1 || true
      '')
    # Keyboard layout cycle helper to handle Hyprland argument changes across versions
    (let
      mkLocalBin = import ../../../../packages/lib/local-bin.nix {inherit lib;};
    in
      mkLocalBin "kb-layout-next" ''#!/usr/bin/env bash
        set -euo pipefail

        try() { hyprctl dispatch "$@" >/dev/null 2>&1; }

        # 1) Newer syntax: global cycle
        if try switchxkblayout next; then exit 0; fi

        # 2) Older syntax: current device cycle
        if try switchxkblayout current next; then exit 0; fi

        # 3) Target a specific device by name and cycle (skip power/sleep buttons)
        dev=$(hyprctl -j devices 2>/dev/null \
          | jq -r '.keyboards[]
              | select((.name|test("^(power-button|sleep-button)$")|not))
              | select((.active? == true) or (.main? == true) or (.enabled? == true) or (.name != null))
              | .name' \
          | head -n1 || true)
        if [[ -n "${dev:-}" ]]; then
          if try switchxkblayout "device:${dev}" next; then exit 0; fi
          if try switchxkblayout "${dev}" next; then exit 0; fi

          # 4) Compute next index (fallback): idx = (idx+1) % len
          json=$(hyprctl -j devices 2>/dev/null || echo '{}')
          # Support multiple field names across Hyprland versions
          idx=$(printf "%s" "$json" \
            | jq -r --arg n "$dev" '.keyboards[]
                | select(.name==$n)
                | (.active_layout_index // .xkb_active_layout_index // .active_keymap_index // -1)')
          # Prefer explicit layout names array if present, else derive from comma-separated string
          len=$(printf "%s" "$json" \
            | jq -r --arg n "$dev" '
                .keyboards[] | select(.name==$n)
                | if (.xkb_layout_names // empty) then (.xkb_layout_names | length)
                  elif (.layouts // empty) then (.layouts | length)
                  elif (.layout // empty) then ((.layout | tostring | split(",") | length))
                  else 0 end')
          if [[ ${idx:- -1} -ge 0 && ${len:- 0} -gt 0 ]]; then
            next=$(( (idx + 1) % len ))
            if try switchxkblayout "device:${dev}" "$next"; then exit 0; fi
            if try switchxkblayout "${dev}" "$next"; then exit 0; fi
          fi
        fi

        # If all attempts failed, surface a friendly error
        echo "Failed to switch XKB layout (tried multiple Hyprland dispatcher variants)" >&2
        exit 1
      '')
    {
      wayland.windowManager.hyprland = {
        enable = true;
        # Use the pinned Hyprland from flake inputs to match the hy3 plugin ABI.
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = null;
        settings = {
          source = [
            # Apply permissions first so plugin load is allowed
            "${config.xdg.configHome}/hypr/permissions.conf"
            # Load plugins (hy3) before the rest of the config
            "${config.xdg.configHome}/hypr/plugins.conf"
            "${config.xdg.configHome}/hypr/init.conf"
          ];
        };
        systemd.variables = ["--all"];
      };
      home.packages = config.lib.neg.pkgsList (
        let
          groups = {
            core = [
              pkgs.hyprcursor # modern cursor theme format (replaces xcursor)
              pkgs.hypridle # idle daemon
              pkgs.hyprpicker # color picker
              pkgs.hyprpolkitagent # polkit agent
              pkgs.hyprprop # xprop-like tool for Hyprland
              pkgs.hyprutils # core utils for Hyprland
              pkgs.pyprland # Hyprland plugin system
              pkgs.upower # power management daemon
            ]
            ++ lib.optional (raiseProvider != null) (raiseProvider pkgs);
            qt = [
              pkgs.hyprland-qt-support # Qt integration fixes
              pkgs.kdePackages.qt6ct # Qt6 config tool
            ];
            tools = [hyprWinList]; # helper: list windows from Hyprctl JSON
          };
          flags = {
            core = true;
            tools = true;
            qt = config.features.gui.qt.enable;
          };
        in
          config.lib.neg.mkEnabledList flags groups
      );
      programs.hyprlock.enable = true;
    }
    # Ensure polkit agent starts in a Wayland session and uses the graphical preset.
    {
      systemd.user.services.hyprpolkitagent = lib.mkMerge [
        {
          Unit.Description = "Hyprland Polkit Agent";
          Service = {
            ExecStart = let
              exe = lib.getExe' pkgs.hyprpolkitagent "hyprpolkitagent";
            in "${exe}";
            Environment = [
              "QT_QPA_PLATFORM=wayland"
              "XDG_SESSION_TYPE=wayland"
            ];
            Restart = "on-failure";
            RestartSec = "2s";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })
      ];
    }
    # Core config files from repo
    (lib.mkMerge (map mkHyprSource coreFiles))
    # Dynamically generated plugin loader: point at the exact store path for hy3
    (let
      # Resolve hy3 plugin for the current system; keep out of closure churn elsewhere
      hy3Pkg = hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3;
      pluginPath = "${hy3Pkg}/lib/libhy3.so";
    in
      xdg.mkXdgText "hypr/plugins.conf" ''
        # Hyprland plugins
        plugin = ${pluginPath}
      ''
    )
    # Overwrite existing generated config files if present
    { xdg.configFile."hypr/plugins.conf".force = true; }
    # Keep the hy3 plugin alive in the profile to avoid GC removing the path
    { home.packages = [ (hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3) ]; }
  ])
