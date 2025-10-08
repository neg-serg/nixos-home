{ pkgs, lib, config, ... }:
with lib;
lib.mkMerge [
  {
    systemd.user.startServices = true;
  }
  (lib.mkIf (config.features.gui.enable or false)
    (let
      picDirsRunner = pkgs.writeShellApplication {
        name = "pic-dirs-runner";
        text = ''
          set -euo pipefail
          exec pic-dirs-list
        '';
      };
    in {
      # Quickshell session (Qt-bound, skip in dev-speed) + other services
      systemd.user.services = lib.mkMerge [
        (lib.mkIf ((config.features.gui.qt.enable or false) && (! (config.features.devSpeed.enable or false))) {
          quickshell =
            lib.mkMerge [
              {
                Unit.Description = "Quickshell Wayland shell";
                Service = {
                  ExecStart = let
                    wrapped = (config.neg.quickshell.wrapperPackage or null);
                    pkg = if wrapped != null then wrapped else pkgs.quickshell;
                    exe = lib.getExe' pkg "qs";
                  in "${exe}";
                  Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
                  Restart = "on-failure";
                  RestartSec = "1";
                  Slice = "background-graphical.slice";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })
            ];
        })
        {
          # Pyprland daemon (Hyprland helper)
          pyprland =
            lib.mkMerge [
              {
                Unit.Description = "Pyprland daemon for Hyprland";
                Service = {
                  Type = "simple";
                  ExecStart = let exe = lib.getExe' pkgs.pyprland "pypr"; in "${exe}";
                  Restart = "on-failure";
                  RestartSec = "1";
                  Slice = "background-graphical.slice";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })
            ];

          ydotoold =
            lib.mkMerge [
              {
                Unit.Description = "ydotool virtual input daemon";
                Service = {
                  ExecStart = lib.getExe' pkgs.ydotool "ydotoold";
                  Restart = "on-failure";
                  RestartSec = "2";
                  Slice = "background-graphical.slice";
                  CapabilityBoundingSet = "CAP_SYS_ADMIN CAP_SYS_TTY_CONFIG CAP_SYS_NICE";
                  AmbientCapabilities = "CAP_SYS_ADMIN CAP_SYS_TTY_CONFIG CAP_SYS_NICE";
                  NoNewPrivileges = false;
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; })
            ];

          # Pic dirs notifier
          "pic-dirs" =
            lib.mkMerge [
              {
                Unit = { Description = "Pic dirs notification"; StartLimitIntervalSec = "0"; };
                Service = {
                  ExecStart = let exe = "${picDirsRunner}/bin/pic-dirs-runner"; in "${exe}";
                  PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
                  Restart = "on-failure";
                  RestartSec = "1";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; })
            ];

          # OpenRGB daemon
          openrgb =
            lib.mkMerge [
              {
                Unit = {
                  Description = "OpenRGB daemon with profile";
                  PartOf = ["graphical-session.target"];
                };
                Service = {
                  ExecStart = let exe = lib.getExe pkgs.openrgb; args = [ "--server" "-p" "neg.orp" ]; in "${exe} ${lib.escapeShellArgs args}";
                  RestartSec = "30";
                  StartLimitBurst = "8";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {
                presets = ["dbusSocket" "defaultWanted"];
              })
            ];
        }
      ];
    }))
]
