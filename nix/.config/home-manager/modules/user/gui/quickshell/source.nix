{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  systemctl = lib.getExe' pkgs.systemd "systemctl";
in
mkIf (config.features.gui.enable && (config.features.gui.qt.enable or false) && (config.features.gui.quickshell.enable or false)) {
  home.file.".config/quickshell" = {
    recursive = true;
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/quickshell/.config/quickshell";
  };

  # After linking the updated config, ask the running quickshell to reload.
  # If reload is unsupported or fails, try a restart only when active.
  home.activation.quickshell-reload = lib.hm.dag.entryAfter ["linkGeneration"] ''
    set -e
    if "${systemctl}" --user is-active -q quickshell.service; then
      "${systemctl}" --user reload quickshell.service || "${systemctl}" --user try-restart quickshell.service || true
    fi
  '';
}
