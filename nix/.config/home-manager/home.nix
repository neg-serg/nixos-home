{pkgs, ...}: {
  nix.package = pkgs.nix;
  imports = [
    ./dotfiles.nix
    ./pkgs
    ./sops.nix
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
