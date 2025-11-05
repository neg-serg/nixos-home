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
          # Avoid import-from-derivation during eval: leave extensions empty by default.
          # Add Raycast/Vicinae extensions explicitly in a follow-up once HM allows builds.
          extensions = [];
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
