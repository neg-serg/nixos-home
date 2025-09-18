{ lib, config, pkgs, xdg ? import ../../lib/xdg-helpers.nix { inherit lib; }, ... }:
lib.mkMerge [
  {
    # Ensure rmpc is installed
    home.packages = config.lib.neg.pkgsList [pkgs.rmpc];
  }
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "rmpc" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/media/audio/rmpc/conf";
    recursive = true;
  })
]
