{ lib, config, ... }:
with lib;
  mkIf config.features.mail.enable (
    let xdg = import ../../../lib/xdg-helpers.nix { inherit lib; };
    in lib.mkMerge [
      (xdg.mkXdgSource "mutt" { source = ./conf; })
    ]
  )
