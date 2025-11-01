{
  pkgs,
  lib,
  config,
  ...
}:
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
        # Floorp package name changed upstream; prefer floorp-bin where available.
        floorpPkg =
          if builtins.hasAttr "floorp-bin" pkgs then pkgs."floorp-bin"
          else if builtins.hasAttr "floorp" pkgs then pkgs.floorp
          else pkgs.emptyFile;
      in {
        # Quickshell session (Qt-bound, skip in dev-speed) + other services
        systemd.user.services = lib.mkMerge [
          (lib.mkIf ((config.features.gui.qt.enable or false) && (! (config.features.devSpeed.enable or false))) {
            quickshell = lib.mkMerge [
              {
                Unit.Description = "Quickshell Wayland shell";
                Service = {
                  ExecStart = let
                    wrapped = config.neg.quickshell.wrapperPackage or null;
                    pkg =
                      if wrapped != null
                      then wrapped
                      else pkgs.quickshell;
                    exe = lib.getExe' pkg "qs";
                  in "${exe}";
                  Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
                  Restart = "on-failure";
                  RestartSec = "1";
                  Slice = "background-graphical.slice";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];})
            ];
          })
          {
            # Floorp browser (autostart via systemd instead of Hypr exec-once)
            floorp = lib.mkMerge [
              {
                Unit = {
                  Description = "Floorp browser";
                };
                Service = {
                  ExecStart = let exe = lib.getExe floorpPkg; in "${exe}";
                  TimeoutStopSec = "5s";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {
                presets = ["graphical"];
                partOf = ["graphical-session.target"];
              })
            ];

            # Nicotine+ (Soulseek client)
            nicotine = lib.mkMerge [
              {
                Unit = {
                  Description = "Nicotine+ (Soulseek client)";
                };
                Service = {
                  ExecStart = let exe = lib.getExe pkgs.nicotine-plus; in "${exe}";
                  TimeoutStopSec = "5s";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {
                presets = ["graphical"];
                partOf = ["graphical-session.target"];
              })
            ];

            # Obsidian (Flatpak preferred, fallback to native if present)
            obsidian = lib.mkMerge [
              {
                Unit = {
                  Description = "Obsidian";
                };
                Service = {
                  # Use a shell to keep the original flatpak-or-native behavior
                  ExecStart = let sh = lib.getExe pkgs.bash; in ''
                    ${sh} -lc 'flatpak run md.obsidian.Obsidian || exec obsidian'
                  '';
                  TimeoutStopSec = "5s";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {
                presets = ["graphical"];
                partOf = ["graphical-session.target"];
              })
            ];

            # Walker app launcher background service
            walker = lib.mkMerge [
              {
                Unit = {
                  Description = "Walker GApplication service";
                };
                Service = {
                  ExecStart = let exe = lib.getExe pkgs.walker; in "${exe} --gapplication-service";
                  TimeoutStopSec = "5s";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {
                presets = ["graphical"];
                partOf = ["graphical-session.target"];
              })
            ];

            # Hypridle idle daemon
            hypridle = lib.mkMerge [
              {
                Unit = {
                  Description = "Hypridle daemon";
                };
                Service = {
                  ExecStart = let exe = lib.getExe pkgs.hypridle; in "${exe}";
                  TimeoutStopSec = "5s";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {
                presets = ["graphical"];
                partOf = ["graphical-session.target"];
              })
            ];

            # Pyprland daemon (Hyprland helper)
            pyprland = lib.mkMerge [
              {
                Unit.Description = "Pyprland daemon for Hyprland";
                Service = {
                  Type = "simple";
                  ExecStart = let exe = lib.getExe' pkgs.pyprland "pypr"; in "${exe}";
                  Restart = "on-failure";
                  RestartSec = "1";
                  Slice = "background-graphical.slice";
                  TimeoutStopSec = "5s";
                };
                Unit.PartOf = ["graphical-session.target"];
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];})
            ];

            # Pic dirs notifier
            "pic-dirs" = lib.mkMerge [
              {
                Unit = {
                  Description = "Pic dirs notification";
                  StartLimitIntervalSec = "0";
                };
                Service = {
                  ExecStart = let exe = lib.getExe' picDirsRunner "pic-dirs-runner"; in "${exe}";
                  PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
                  Restart = "on-failure";
                  RestartSec = "1";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["defaultWanted"];})
            ];

            # OpenRGB daemon
            openrgb = lib.mkMerge [
              {
                Unit = {
                  Description = "OpenRGB daemon with profile";
                  PartOf = ["graphical-session.target"];
                };
                Service = {
                  ExecStart = let
                    exe = lib.getExe pkgs.openrgb;
                    args = ["--server" "-p" "neg.orp"];
                  in "${exe} ${lib.escapeShellArgs args}";
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
