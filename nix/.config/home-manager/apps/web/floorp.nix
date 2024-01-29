{ config, lib, pkgs, ... }: {
  home.packages = [ pkgs.floorp ]; # Module installing  as default browser
  home.sessionVariables = { DEFAULT_BROWSER = "${pkgs.floorp}/bin/floorp"; };
  xdg.mimeApps.defaultApplications = {
      "text/html" = "floorp.desktop";
      "x-scheme-handler/http" = "floorp.desktop";
      "x-scheme-handler/https" = "floorp.desktop";
      "x-scheme-handler/about" = "floorp.desktop";
      "x-scheme-handler/unknown" = "floorp.desktop";
  };
}
