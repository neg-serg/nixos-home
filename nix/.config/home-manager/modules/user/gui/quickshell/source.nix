{
  lib,
  config,
  xdg,
  ...
}:
with lib;
  mkIf (config.features.gui.enable && (config.features.gui.qt.enable or false) && (! (config.features.devSpeed.enable or false))) (
    xdg.mkXdgSource "quickshell" {
      # Keep Quickshell config with other modules under this repo
      # Use an out-of-store symlink so edits apply immediately without a switch
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/quickshell/conf";
      recursive = true;
    }
  )
