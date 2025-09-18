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
  }

  # Quickshell session
  (config.lib.neg.systemdUser.mkSimpleService {
    name = "quickshell";
    description = "Quickshell Wayland shell";
    execStart = "${lib.getExe' pkgs.quickshell "qs"}";
    presets = ["graphical"];
    serviceExtra = {
      Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
      Restart = "on-failure";
      RestartSec = "1";
      Slice = "background-graphical.slice";
    };
  })

  # Pyprland daemon
  (config.lib.neg.systemdUser.mkSimpleService {
    name = "pyprland";
    description = "Pyprland daemon for Hyprland";
    execStart = "${lib.getExe' pkgs.pyprland "pypr"}";
    presets = ["graphical"];
    serviceExtra = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "1";
      Slice = "background-graphical.slice";
    };
  })

  # Pic dirs notifier
  (config.lib.neg.systemdUser.mkSimpleService {
    name = "pic-dirs";
    description = "Pic dirs notification";
    execStart = "${picDirsRunner}/bin/pic-dirs-runner";
    presets = ["defaultWanted"];
    unitExtra = { StartLimitIntervalSec = "0"; };
    serviceExtra = {
      PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
      Restart = "on-failure";
      RestartSec = "1";
    };
  })

  # OpenRGB daemon
  (config.lib.neg.systemdUser.mkSimpleService {
    name = "openrgb";
    description = "OpenRGB daemon with profile";
    execStart = "${lib.getExe pkgs.openrgb} --server -p neg.orp";
    presets = ["defaultWanted" "dbusSocket"];
    partOf = ["graphical-session.target"];
    serviceExtra = {
      RestartSec = "30";
      StartLimitBurst = "8";
    };
  })

  # (ydotoold service removed by request)
]
