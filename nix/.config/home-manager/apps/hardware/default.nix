{ lib, config, pkgs, ... }: {
  imports = [
      ./hid.nix
      ./info.nix
  ];
}
