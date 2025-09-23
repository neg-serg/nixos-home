{ lib, pkgs, config, xdg, ... }:
with lib;
mkIf config.features.gui.enable (
  lib.mkMerge [
  {
    home.packages = config.lib.neg.pkgsList [
      pkgs.rofi-pass-wayland # pass interface for rofi-wayland
      config.neg.rofi.package # modern dmenu alternative with plugins
    ];
  }
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "rofi" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/rofi/conf";
    recursive = true;
  })
])
