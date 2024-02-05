{ lib, config, pkgs, ... }: {
  imports = [
      ./misc.nix
      ./games.nix
      ./emulators.nix
      ./launchers.nix
  ];
}
