{
  lib,
  pkgs,
  config,
  iwmenuProvider ? null,
  ...
}:
with lib;
  mkIf config.features.gui.enable (
    let
      devSpeed = config.features.devSpeed.enable or false;
      groups = {
        core = [
          pkgs.dragon-drop # drag-n-drop from console
          pkgs.gowall # generate palette from wallpaper
          pkgs.grimblast # Hyprland screenshot helper
          pkgs.grim # take Wayland screenshots
          pkgs.slurp # select region in Wayland compositor
          pkgs.swww # Wayland wallpaper daemon
          pkgs.waybar # Wayland status bar
          pkgs.waypipe # Wayland remoting (ssh -X like)
          pkgs.wev # xev for Wayland
          pkgs.wf-recorder # screen recording
          pkgs.wl-clipboard # copy/paste for Wayland
          pkgs.wl-clip-persist # persist clipboard across app exits
          pkgs.wtype # fake typing for Wayland
        ];
        extras = lib.optionals (! devSpeed && (iwmenuProvider != null)) [
          (iwmenuProvider pkgs) # Wayland app launcher/menu from flake input
        ];
      };
      flags = {
        core = true;
        extras = true;
      };
    in {
      home.packages = config.lib.neg.pkgsList (config.lib.neg.mkEnabledList flags groups);
    }
  )
