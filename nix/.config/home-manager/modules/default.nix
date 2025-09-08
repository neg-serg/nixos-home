{ lib, config, ... }:
with lib;
let
  cfg = config.features;
in {
  imports = [
    ./features.nix
    ./cli
    ./db
    ./dev
    ./distros
    ./flatpak
    ./hardware
    ./main
    ./media
    ./misc
    ./secrets
    ./text
    ./user
  ];
}
