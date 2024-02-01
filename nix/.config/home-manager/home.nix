{ lib, config, pkgs, ... }:
with rec {
    home_vars = {
        __GL_GSYNC_ALLOWED = "0"; # picom/compositing compatibility(for now)
        __GL_VRR_ALLOWED = "0"; # picom/compositing compatibility(for now)
        _JAVA_AWT_WM_NONEREPARENTING = "1";
        MOZ_DBUS_REMOTE = "1";
        MOZ_ENABLE_WAYLAND = "1";
        WLR_BACKEND = "vulkan"; # nvidia compatibility
        WLR_DRM_NO_ATOMIC = "1";
        WLR_NO_HARDWARE_CURSORS = "1"; # nvidia compatibility
        WLR_RENDERER = "vulkan"; # nvidia compatibility
    };
};{
  nix.package = pkgs.nix;
  imports = [
    ./pkgs.nix
    ./xdg.nix
    ./theme.nix
    ./dotfiles.nix
    ./sops.nix

    ./apps/android.nix
    ./apps/archives.nix
    ./apps/audio/apps.nix
    ./apps/audio/core.nix
    ./apps/benchmarks.nix
    ./apps/btop.nix
    ./apps/cli.nix
    ./apps/dev.nix
    ./apps/distros.nix
    ./apps/fetch.nix
    ./apps/fun/emulators.nix
    ./apps/fun/games.nix
    ./apps/fun/launchers.nix
    ./apps/fun/misc.nix
    ./apps/gpg.nix
    ./apps/hack.nix
    ./apps/hardware/info.nix
    ./apps/hid.nix
    ./apps/im.nix
    ./apps/images.nix
    ./apps/mail.nix
    ./apps/neovim.nix
    ./apps/pass.nix
    ./apps/pics_and_fonts.nix
    ./apps/terminal.nix
    ./apps/text/manipulate.nix
    ./apps/text/notes.nix
    ./apps/text/read.nix
    ./apps/torrent.nix
    ./apps/vulnerability_scanners.nix
    ./apps/web/browsing.nix
    ./apps/web/misc.nix
    ./apps/x11/apps.nix
    ./apps/x11/rofi.nix
    ./apps/x11/stuff.nix
    ./apps/xdg.nix
    ./apps/yubikey.nix

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

  manual.manpages.enable = false;

  programs = {
      home-manager.enable = true; # Let Home Manager install and manage itself.
      mangohud.enable = true; # gaming hud
      neovim.plugins = with pkgs; [ vimPlugins.nvim-treesitter.withAllGrammars ];
  };

  home = {
      homeDirectory = "/home/neg";
      stateVersion = "23.11"; # Please read the comment before changing.
      username = "neg";
      sessionVariables = home_vars;
  };
}
