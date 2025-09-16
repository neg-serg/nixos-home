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
with lib; {
  systemd.user.startServices = true;

  # Quickshell session
  systemd.user.services.quickshell = lib.recursiveUpdate {
    Unit.Description = "Quickshell Wayland shell";
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
      Restart = "on-failure";
      RestartSec = "1";
      Slice = "background-graphical.slice";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; });

  # Pyprland daemon
  systemd.user.services.pyprland = lib.recursiveUpdate {
    Unit.Description = "Pyprland daemon for Hyprland";
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.pyprland}/bin/pypr";
      Restart = "on-failure";
      RestartSec = "1";
      Slice = "background-graphical.slice";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; });

  # Pic dirs notifier
  systemd.user.services."pic-dirs" = lib.recursiveUpdate {
    Unit = {
      Description = "Pic dirs notification";
      StartLimitIntervalSec = "0";
    };
    Service = {
      ExecStart = "${picDirsRunner}/bin/pic-dirs-runner";
      PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
      Restart = "on-failure";
      RestartSec = "1";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; });

  # OpenRGB daemon
  systemd.user.services.openrgb = lib.recursiveUpdate {
    Unit.Description = "OpenRGB daemon with profile";
    Service = {
      ExecStart = "${pkgs.openrgb}/bin/openrgb --server -p neg.orp";
      RestartSec = "30";
      StartLimitBurst = "8";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {
    presets = ["defaultWanted" "dbusSocket"];
    partOf = ["graphical-session.target"];
  });

  # ydotoold (input emulation daemon)
  # Requires access to /dev/uinput (system-level udev rules and group membership).
  systemd.user.services.ydotoold = lib.mkIf config.features.cli.sys (
    lib.recursiveUpdate {
      Unit = {
        Description = "ydotool daemon";
        ConditionPathExists = "/dev/uinput";
        StartLimitIntervalSec = "0";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.ydotool}/bin/ydotoold";
        Restart = "on-failure";
        RestartSec = "2";
        Slice = "background-graphical.slice";
      };
    } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })
  );
}
