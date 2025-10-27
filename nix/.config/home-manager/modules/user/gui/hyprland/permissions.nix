{ lib, config, pkgs, xdg, ... }:
with lib; mkIf config.features.gui.enable (
  xdg.mkXdgText "hypr/permissions.conf" ''
    ecosystem {
      enforce_permissions = 1
    }
    permission = ${lib.getExe pkgs.grim}, screencopy, allow
    permission = ${lib.getExe pkgs.hyprlock}, screencopy, allow
  ''
)
