{pkgs, ...}: {
  nix.package = pkgs.nix;
  imports = [
    ./secrets
    ./modules
  ];
  home = {
    homeDirectory = "/home/neg";
    stateVersion = "23.11"; # Please read the comment before changing.
    username = "neg";
  };
}
