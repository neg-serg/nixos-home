{...}: {
  systemd.user.sessionVariables = {
    GDK_BACKEND = "x11";
    XDG_CURRENT_DESKTOP = "i3";
    XDG_SESSION_DESKTOP = "i3";
    XDG_SESSION_TYPE = "x11";
  };
}
