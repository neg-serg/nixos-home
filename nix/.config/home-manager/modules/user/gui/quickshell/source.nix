{
  lib,
  config,
  ...
}:
with lib;
mkIf (config.features.gui.enable && (config.features.gui.qt.enable or false) && (config.features.gui.quickshell.enable or false)) {
  home.file.".config/quickshell" = {
    recursive = true;
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/quickshell/.config/quickshell";
  };
}
