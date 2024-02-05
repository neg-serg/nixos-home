{ lib, config, pkgs, ... }: {
  imports = [
      ./apps.nix
      ./rofi.nix
      ./stuff.nix
  ];
}
