{ pkgs, ... }: {
  nix.package = pkgs.nix;
  imports = [
    ./dotfiles.nix
    ./sops.nix
    ./systemd
    ./theme
    ./xdg.nix

    ./apps/android.nix
    ./apps/archives.nix
    ./apps/audio
    ./apps/benchmarks.nix
    ./apps/btop.nix
    ./apps/cli.nix
    ./apps/dev.nix
    ./apps/distros.nix
    ./apps/fetch.nix
    ./apps/fonts
    ./apps/fun
    ./apps/gpg.nix
    ./apps/hack.nix
    ./apps/hardware
    ./apps/im
    ./apps/images
    ./apps/mail.nix
    ./apps/media
    ./apps/neovim.nix
    ./apps/pass.nix
    ./apps/sway.nix
    ./apps/terminal
    ./apps/text
    ./apps/torrent
    ./apps/vulnerability_scanners.nix
    ./apps/web
    ./apps/x11
    ./apps/yubikey.nix
    ./misc-pkgs.nix
  ];

  services = {
      udiskie = { enable = true; };
      mpdris2 = { enable = false; };
  };

  manual = {
      html.enable = false;
      json.enable = false;
      manpages.enable = true;
  };

  programs = {
      home-manager.enable = true; # Let Home Manager install and manage itself.
      zsh.enable = true;
      mangohud.enable = true; # gaming hud
  };

  home = {
      homeDirectory = "/home/neg";
      stateVersion = "23.11"; # Please read the comment before changing.
      username = "neg";
  };
}
