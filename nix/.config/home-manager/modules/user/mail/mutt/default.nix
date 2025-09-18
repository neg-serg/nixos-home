{ lib, config, xdg ? import ../../../lib/xdg-helpers.nix { inherit lib; }, ... }:
with lib;
  mkIf config.features.mail.enable (
    lib.mkMerge [
      (xdg.mkXdgSource "mutt" { source = ./conf; })
    ]
  )
