{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  programs.distrobox = {
    enable = true; # tool try various distros in cli
  };
}
