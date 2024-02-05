{ lib, config, pkgs, ... }: {
  imports = [
      ./read.nix
      ./notes.nix
      ./manipulate.nix
  ];
}
