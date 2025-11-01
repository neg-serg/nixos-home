{
  lib,
  config,
  xdg,
  ...
}:
with lib;
  mkIf (config.features.gui.enable && (config.features.gui.qt.enable or false) && (! (config.features.devSpeed.enable or false))) (
    xdg.mkXdgSource "quickshell" {
      # Link the maintained Quickshell config tree from repository root
      # Out-of-store symlink: edits apply immediately without rebuild
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/quickshell/.config/quickshell";
      recursive = true;
    }
  )
