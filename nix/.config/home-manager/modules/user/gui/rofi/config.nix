{ lib, pkgs, config, xdg, ... }:
with lib;
mkIf config.features.gui.enable (let
  rofiPkg = pkgs.rofi.override {
    plugins = [
      pkgs.rofi-file-browser
      pkgs.neg.rofi_games
    ];
  };
in lib.mkMerge [
  {
    home.packages = config.lib.neg.pkgsList [
      pkgs.rofi-pass-wayland # pass interface for rofi-wayland
      rofiPkg # modern dmenu alternative with plugins
    ];
  }
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "rofi" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/rofi/conf";
    recursive = true;
  })
])
