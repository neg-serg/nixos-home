{ config, pkgs, ... }:
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
              "misc-x.service"
              "negwm-autostart.service"
              "negwm.service"
              "polybar.service"
              "unclutter.service"
              "ssh-agent.service"
          ];
      };
  };
}
