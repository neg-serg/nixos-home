{ lib, config, pkgs, ... }: {
  imports = [
      ./misc.nix
      ./floorp.nix
      ./browsing.nix
  ];
}
