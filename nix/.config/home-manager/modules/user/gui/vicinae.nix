{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
  # Enable Vicinae when GUI is on and provide sane defaults.
  mkIf config.features.gui.enable (
    lib.mkMerge [
      {
        programs.vicinae = {
          enable = true;
          # Prefer Wayland layer-shell integration for proper stacking on Hyprland
          useLayerShell = true;
          # Lightweight base config; Vicinae reads this as JSON at $XDG_CONFIG_HOME/vicinae/vicinae.json
          settings = {};
          # Autostart the daemon in graphical sessions via systemd user unit
          systemd = {
            enable = true;
            autoStart = true;
            target = "graphical-session.target";
          };
          # Provide at least one extension using the built-in Raycast helper
          extensions = [
            (config.lib.vicinae.mkRayCastExtension {
              name = "gif-search";
              # From upstream docs; rev/sha pinned for reproducibility
              rev = "4d417c2dfd86a5b2bea202d4a7b48d8eb3dbaeb1";
              sha256 = "sha256-G7il8T1L+P/2mXWJsb68n4BCbVKcrrtK8GnBNxzt73Q=";
            })
          ];
          # Drop a minimal theme placeholder; not selected unless explicitly referenced by settings
          themes = {
            neg = {
              # Keep minimal to avoid coupling to a specific Vicinae theme schema
              name = "neg";
            };
          };
        };
      }
    ]
  )

