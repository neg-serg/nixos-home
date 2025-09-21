{ lib, pkgs, config, iwmenuProvider ? null, ... }:
with lib;
mkIf config.features.gui.enable (
  let
    devSpeed = config.features.devSpeed.enable or false;
    groups = {
      core = [
        pkgs.dragon-drop
        pkgs.gowall
        pkgs.grimblast
        pkgs.grim
        pkgs.slurp
        pkgs.swww
        pkgs.waybar
        pkgs.waypipe
        pkgs.wev
        pkgs.wf-recorder
        pkgs.wl-clipboard
        pkgs.wl-clip-persist
        pkgs.wtype
      ];
      extras = lib.optionals (! devSpeed && (iwmenuProvider != null)) [ (iwmenuProvider pkgs) ];
    };
    flags = { core = true; extras = true; };
  in {
    home.packages = config.lib.neg.pkgsList (config.lib.neg.mkEnabledList flags groups);
  }
)

