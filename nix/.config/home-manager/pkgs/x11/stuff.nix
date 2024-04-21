{pkgs, ...}: {
  home.packages = with pkgs; [
    inputplug # xinput event monitor
    slop # rectangle selection
    unclutter-xfixes # x11 hide cursor via xfixes
    warpd
    wmctrl
    xclip
    xsel # cli for X session clipboard manipulation
    xdo # X11 automation
    xdotool # another X11 automation
    xiccd
    xorg.xev # X11 window to debug events
    xorg.xkill # kill X11 window via cursor or id
    xorg.xset # X11 settings rule
    xsettingsd # manage xdg settings without gnome
    xss-lock
  ];
}
