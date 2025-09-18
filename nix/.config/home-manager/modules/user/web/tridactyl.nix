{ lib, config, xdg ? import ../../lib/xdg-helpers.nix { inherit lib; }, ... }:
with lib;
  mkIf config.features.web.enable (lib.mkMerge [
    # Live-editable config via helper (guards parent dir and target)
    (xdg.mkXdgSource "tridactyl" {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/misc/.config/tridactyl";
      recursive = true;
    })
  ])
