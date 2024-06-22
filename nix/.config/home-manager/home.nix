{
  pkgs,
  lib,
  ...
}: {
  nix.package = pkgs.nix;
  imports = [
    ./envs.nix
    ./dotfiles.nix
    ./pkgs
    ./secrets
    ./systemd
    ./theme
    ./xdg.nix
  ];
  home = {
    homeDirectory = "/home/neg";
    stateVersion = "23.11"; # Please read the comment before changing.
    username = "neg";
  };
}
