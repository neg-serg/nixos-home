{
  lib,
  config,
  # pkgs not used here
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
          # Local extension to avoid IFD (no remote fetch/build during eval)
          extensions = [
            (config.lib.vicinae.mkExtension {
              name = "neg-hello";
              src = ./vicinae/extensions/neg-hello;
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
