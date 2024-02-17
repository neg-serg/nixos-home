{ pkgs, ... }:
with {
    home_vars = {
        __GL_GSYNC_ALLOWED = "0"; # picom/compositing compatibility(for now)
        __GL_VRR_ALLOWED = "0"; # picom/compositing compatibility(for now)
        _JAVA_AWT_WM_NONEREPARENTING = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
    };
};{
  nix.package = pkgs.nix;
  imports = [
    ./xdg.nix
    ./theme.nix
    ./sops.nix
    ./dotfiles.nix

    ./apps/android.nix
    ./apps/archives.nix
    ./apps/audio
    ./apps/benchmarks.nix
    ./apps/btop.nix
    ./apps/cli.nix
    ./apps/dev.nix
    ./apps/distros.nix
    ./apps/fetch.nix
    ./apps/fun
    ./apps/gpg.nix
    ./apps/hack.nix
    ./apps/hardware
    ./apps/im.nix
    ./apps/images
    ./apps/mail.nix
    ./apps/neovim.nix
    ./apps/pass.nix
    ./apps/fonts
    ./apps/terminal
    ./apps/text
    ./apps/torrent
    ./apps/vulnerability_scanners.nix
    ./apps/web
    ./apps/x11
    ./apps/yubikey.nix
    ./misc_pkgs.nix
    
    ./systemd/targets.nix
    ./systemd/services.nix
  ];

  services = {
      udiskie = { enable = true; };
      mpdris2 = { enable = false; };
  };

  systemd.user.sessionVariables = {
      GDK_BACKEND = "x11";
      XDG_CURRENT_DESKTOP = "i3";
      XDG_SESSION_DESKTOP = "i3";
      XDG_SESSION_TYPE = "x11";
  };

  qt = {
      enable = true;
      platformTheme = "qtct";
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
      sessionVariables = home_vars;
  };
}
