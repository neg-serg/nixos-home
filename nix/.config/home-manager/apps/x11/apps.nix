{ config, pkgs, negwmPkg, ... }: {
  home.packages = with pkgs; [
      dunst # notification daemon
      flameshot # interactive screenshot tool
      herbe # notification without daemon and dbus
      hsetroot # set x11 root image
      i3 # my favorite wm
      i3lock-fancy-rapid
      maim # screenshot tool for x11
      picom # x11 compositing
      polybar # my favorite panel so far
      negwmPkg.negwm
    ];
}
