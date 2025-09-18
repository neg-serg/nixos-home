{ lib, config, pkgs, ... }:
let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
  # Install tig and provide its configuration via XDG
  home.packages = config.lib.neg.pkgsList [pkgs.tig];
  }
  (xdg.mkXdgText "tig/config" (builtins.readFile ./tig.conf))
]
