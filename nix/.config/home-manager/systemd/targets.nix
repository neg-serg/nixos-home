{
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };

  systemd.user.targets.i3-session = {
    Unit = {
      Description = "X session";
      BindsTo = ["i3.service"];
      Wants = [
        "executor.service"
        "negwm-autostart.service"
        "negwm.service"
      ];
    };
  };

  # systemd.user.targets.sway-session = {
  #       Unit = {
  #           Description = "sway compositor session";
  #           Documentation = "man:systemd.special(7)";
  #           BindsTo = ["graphical-session.target"];
  #           Wants = ["graphical-session-pre.target"];
  #           After = ["graphical-session-pre.target"];
  #       };
  # };
}
