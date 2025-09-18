{ lib, xdg ? import ../../lib/xdg-helpers.nix { inherit lib; }, ... }:
lib.mkMerge [
  (xdg.mkXdgText "ncpamixer.conf" (builtins.readFile ./ncpamixer.conf))
]
