{ lib, config, pkgs, ... }: {
  imports = [
      ./apps.nix
      ./core.nix
      ./beets.nix
      ./creation.nix
  ];
}
