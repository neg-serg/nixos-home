{master, ...}: {
  # home.packages = [master.floorp]; # Module installing  as default browser
  # home.sessionVariables = {
  #   DEFAULT_BROWSER = "${master.floorp}/bin/floorp";
  #   MOZ_DBUS_REMOTE = "1";
  #   MOZ_ENABLE_WAYLAND = "1";
  # };
  xdg.mimeApps.defaultApplications = {
    "text/html" = "floorp.desktop";
    "x-scheme-handler/http" = "floorp.desktop";
    "x-scheme-handler/https" = "floorp.desktop";
    "x-scheme-handler/about" = "floorp.desktop";
    "x-scheme-handler/unknown" = "floorp.desktop";
  };
}
