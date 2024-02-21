{ pkgs, ... }:
with {
    home_vars = {
        __GL_GSYNC_ALLOWED = "0"; # picom/compositing compatibility(for now)
        __GL_VRR_ALLOWED = "0"; # picom/compositing compatibility(for now)
    };
};{
  nix.package = pkgs.nix;
  imports = [
    ./dotfiles.nix
    ./sops.nix
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
    ./apps/images
    ./apps/im.nix
    ./apps/mail.nix
    ./apps/neovim.nix
    ./apps/pass.nix
    ./apps/terminal
    ./apps/text
    ./apps/torrent
    ./apps/vulnerability_scanners.nix
    ./apps/web
    ./apps/x11
    ./apps/yubikey.nix
    ./misc-pkgs.nix

    ./systemd/targets.nix
    ./systemd/services.nix
  ];

  services = {
      udiskie = { enable = true; };
      mpdris2 = { enable = false; };
  };

  nixpkgs.overlays = [
      # "overwrite" xdg-open with handlr
      (final: prev: {
          # very expensive since this invalidates the cache for a lot of (almost all) graphical apps.
          xdg-utils = prev.xdg-utils.overrideAttrs (oldAttrs: {
              postInstall = oldAttrs.postInstall + ''
                  # "overwrite" xdg-open with handlr
                  cp ${prev.writeShellScriptBin "xdg-open" "${prev.handlr}/bin/handlr open \"$@\""}/bin/xdg-open $out/bin/xdg-open
              '';
          });
      })
  ];

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
