{ lib, config, xdg ? import ../../lib/xdg-helpers.nix { inherit lib; }, ... }:
lib.mkMerge [
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "kitty" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/kitty/conf";
    recursive = true;
  })
]
