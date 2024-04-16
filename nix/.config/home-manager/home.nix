{ pkgs, ... }: {
  nix.package = pkgs.nix;
  imports = [
    ./dotfiles.nix
    ./sops.nix
    ./systemd
    ./theme
    ./xdg.nix
    ./pkgs
  ];

  services = {
      mpdris2 = { enable = false; };
      udiskie = { enable = true; };
  };

  manual = {
      html.enable = false;
      json.enable = false;
      manpages.enable = true;
  };

  programs = {
      home-manager.enable = true; # Let Home Manager install and manage itself.
      mangohud.enable = true; # gaming hud
  };

  home = {
      homeDirectory = "/home/neg";
      stateVersion = "23.11"; # Please read the comment before changing.
      username = "neg";
  };
}
