{ pkgs, negwmPkg, ... }: {
    home.packages = with pkgs; [
        dunst # notification daemon
        flameshot # interactive screenshot tool
        herbe # notification without daemon and dbus
        hsetroot # set x11 root image
        i3lock-fancy-rapid
        i3 # my favorite wm
        maim # screenshot tool for x11
        negwmPkg.negwm # my own i3 helper
        picom # x11 compositing
        polybar # my favorite panel so far
  ];
  services.sxhkd = {
      enable = false;
      keybindings = {};
  };
}
