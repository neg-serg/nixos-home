{ lib, config, pkgs, hy3, xdg, ... }:
with lib; let
  hy3Plugin = hy3.packages.${pkgs.system}.hy3;
in mkIf config.features.gui.enable (
  xdg.mkXdgText "hypr/permissions.conf" ''
    ecosystem {
      enforce_permissions = 1
    }
    permission = ${hy3Plugin}/lib/libhy3.so, plugin, allow
    permission = ${lib.getExe pkgs.grim}, screencopy, allow
    permission = ${lib.getExe pkgs.hyprlock}, screencopy, allow
    plugin = ${hy3Plugin}/lib/libhy3.so
  ''
)

