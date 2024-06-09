{
  pkgs,
  config,
  negwmPkg,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
  i3-get-window-criteria = pkgs.callPackage ../../packages/i3-get-window-criteria {};
  i3-lock-fancy-rapid = pkgs.callPackage ../../packages/i3lock-fancy-rapid {};
  i3-balance-workspace = pkgs.callPackage ../../packages/i3-balance-workspace {};
  rofi-games = pkgs.callPackage ../../packages/rofi-games {};
  # dup-img-finder = pkgs.callPackage ../../packages/dup-img-finder {};
}; {
  home.packages = with pkgs; [
    dunst # notification daemon
    # dup-img-finder # TRY: img duplicates finder
    flameshot # interactive screenshot tool
    herbe # notification without daemon and dbus
    hsetroot # set x11 root image
    i3-balance-workspace # TRY: balance workspaces
    i3-get-window-criteria # xwindowinfo (test)
    i3lock-fancy-rapid # TRY: better lock
    i3 # my favorite wm
    maim # screenshot tool for x11
    negwmPkg.negwm # my own i3 helper
    picom # x11 compositing
    polybar # my favorite panel so far
    rofi-games # TRY: rofi launcher for games
  ];
  services.sxhkd = {
    enable = false;
    keybindings = {};
  };
  xdg.configFile = {
    "polybar" = {
      source = l "${dots}/wm/.config/polybar";
      recursive = true;
    };
  };
  home.file = {
    ".local/bin/polybar-run" = {
      executable = true;
      text = ''
        #!/bin/sh
        killall -KILL polybar
        if [ "$(hostname)" != 'telfir' ]; then
            POLYBAR_DPI="$(echo "$dpi/1.85" | bc)"
        else
            POLYBAR_DPI=65
        fi
        export POLYBAR_DPI
        systemctl --user import-environment POLYBAR_DPI
        polybar main -l error
      '';
    };
  };
}
