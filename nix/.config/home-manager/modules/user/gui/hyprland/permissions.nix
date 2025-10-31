{
  lib,
  config,
  pkgs,
  xdg,
  ...
}:
with lib;
  mkIf config.features.gui.enable (
    xdg.mkXdgText "hypr/permissions.conf" ''
      ecosystem {
        enforce_permissions = 1
      }
      permission = ${lib.getExe pkgs.grim}, screencopy, allow
      permission = ${lib.getExe pkgs.hyprlock}, screencopy, allow
      # Allow loading hy3 plugin. Use a regex to survive path hash/version changes.
      # RE2 full-match is used; keep anchors.
      permission = ^/nix/store/[^/]+-hy3-[^/]+/lib/libhy3\.so$, plugin, allow
      permission = /etc/hypr/libhy3.so, plugin, allow
    ''
  )
