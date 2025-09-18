{ pkgs, lib, config, ... }:
let
  picDirsRunner = pkgs.writeShellApplication {
    name = "pic-dirs-runner";
    text = ''
      set -euo pipefail
      exec "$HOME/bin/pic-dirs-list"
    '';
  };
in
with lib; lib.mkMerge [
  {
    systemd.user.startServices = true;

    # Quickshell session
    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell Wayland shell";
        After = ["graphical-session.target"];
        Wants = ["graphical-session.target"];
      };
      Install.WantedBy = ["graphical-session.target"];
      Service = {
        ExecStart = "${lib.getExe' pkgs.quickshell "qs"}";
        Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
        Restart = "on-failure";
        RestartSec = "1";
        Slice = "background-graphical.slice";
      };
    };

    # Pyprland daemon
    systemd.user.services.pyprland = {
      Unit = {
        Description = "Pyprland daemon for Hyprland";
        After = ["graphical-session.target"];
        Wants = ["graphical-session.target"];
      };
      Install.WantedBy = ["graphical-session.target"];
      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe' pkgs.pyprland "pypr"}";
        Restart = "on-failure";
        RestartSec = "1";
        Slice = "background-graphical.slice";
      };
    };

    # Pic dirs notifier
    systemd.user.services."pic-dirs" = {
      Unit = {
        Description = "Pic dirs notification";
        StartLimitIntervalSec = "0";
      };
      Install.WantedBy = ["default.target"];
      Service = {
        ExecStart = "${picDirsRunner}/bin/pic-dirs-runner";
        PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
        Restart = "on-failure";
        RestartSec = "1";
      };
    };

    # OpenRGB daemon
    systemd.user.services.openrgb = {
      Unit = {
        Description = "OpenRGB daemon with profile";
        After = ["dbus.socket"];
        PartOf = ["graphical-session.target"];
      };
      Install.WantedBy = ["default.target"];
      Service = {
        ExecStart = "${lib.getExe pkgs.openrgb} --server -p neg.orp";
        RestartSec = "30";
        StartLimitBurst = "8";
      };
    };
  }

  # (ydotoold service removed by request)
]
