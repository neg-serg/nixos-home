{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
  mkIf config.features.gui.enable (
    let
      devSpeed = config.features.devSpeed.enable or false;
      groups = {
        core = with pkgs; [
          cliphist # wayland clipboard history
          espanso # system-wide text expander
          matugen # theme generator (pywal-like)
        ];
        # extras evaluated only when enabled (prevents pulling input in dev-speed)
        extras = lib.optionals (! devSpeed) [ inputs.bzmenu.packages.${pkgs.system}.default ];
      };
      flags = {
        core = true;
        extras = true;
      };
    in {
      programs.wallust.enable = true;
      home.packages = config.lib.neg.pkgsList (config.lib.neg.mkEnabledList flags groups);
    }
  )
