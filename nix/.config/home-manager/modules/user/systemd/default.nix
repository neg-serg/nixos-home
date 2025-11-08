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
      in {
        # Quickshell session (Qt-bound, skip in dev-speed) + other services
        systemd.user.services = lib.mkMerge [
          (lib.mkIf ((config.features.gui.qt.enable or false) && (config.features.gui.quickshell.enable or false) && (! (config.features.devSpeed.enable or false))) {
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
                  TimeoutStopSec = "5s";
                };
                Unit.PartOf = ["graphical-session.target"];
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];})
            ];
          })
          {
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

            # Pyprland daemon (Hyprland helper)
            # Use a wrapper that resolves the current HYPRLAND_INSTANCE_SIGNATURE
            # at start time so restarts after Hyprland crashes/restarts are stable.
            pyprland = lib.mkMerge [
              {
                Unit = {
                  Description = "Pyprland daemon for Hyprland";
                  StartLimitIntervalSec = "0";
                  # Start only when a Hyprland instance socket exists
                  ConditionPathExistsGlob = [
                    "%t/hypr/*/.socket.sock"
                    "%t/hypr/*/.socket2.sock"
                  ];
                };
                Service = {
                  Type = "simple";
                  # Wrapper ensures we always target the newest Hypr instance
                  ExecStart = "${config.home.homeDirectory}/.local/bin/pypr-run";
                  Restart = "always";
                  RestartSec = "1s";
                  Slice = "background-graphical.slice";
                  TimeoutStopSec = "5s";
                  # Ensure common env from the user manager is visible
                  PassEnvironment = [
                    "XDG_RUNTIME_DIR"
                    "WAYLAND_DISPLAY"
                    "HYPRLAND_INSTANCE_SIGNATURE"
                  ];
                };
                Unit.PartOf = ["graphical-session.target"];
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];})
            ];

            # OpenRGB daemon
            openrgb = lib.mkMerge [
              {
                Unit = {
                  Description = "OpenRGB daemon with profile";
                  PartOf = ["graphical-session.target"];
                  StartLimitBurst = "8";
                };
                Service = {
                  ExecStart = let
                    exe = lib.getExe pkgs.openrgb;
                    args = ["--server" "-p" "neg.orp"];
                  in "${exe} ${lib.escapeShellArgs args}";
                  RestartSec = "30";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {
                presets = ["dbusSocket" "graphical"];
              })
            ];

            # Watch Hyprland socket and restart pyprland on new instance
            pyprland-watch = lib.mkMerge [
              {
                Unit = {
                  Description = "Restart pyprland on Hyprland instance change";
                  # Disable start-rate limiting; path may trigger bursts on Hypr restarts
                  StartLimitIntervalSec = "0";
                };
                Service = {
                  Type = "oneshot";
                  # Debounce frequent triggers within 2s; ignore errors
                  ExecStart = ''${pkgs.bash}/bin/bash -lc '
                    set -euo pipefail
                    : "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
                    stamp="$XDG_RUNTIME_DIR/hypr/.pyprland-watch.stamp"
                    now=$(date +%s)
                    last=0
                    if [ -f "$stamp" ]; then
                      last=$(date +%s -r "$stamp" 2>/dev/null || echo 0)
                    fi
                    if [ $((now - last)) -lt 2 ]; then
                      exit 0
                    fi
                    touch "$stamp"
                    exec ${pkgs.systemd}/bin/systemctl --user try-restart pyprland.service >/dev/null 2>&1 || true
                  '''';
                  SuccessExitStatus = ["0"]; # explicit for clarity
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];})
            ];
          }
        ];
        # Path unit triggers the oneshot service whenever a new hypr socket appears
        systemd.user.paths.pyprland-watch = lib.mkMerge [
          {
            Unit = {
              Description = "Watch Hyprland socket path";
              # Also disable rate limiting on the path unit itself
              StartLimitIntervalSec = "0";
            };
            Path = {
              # Trigger when hypr creates sockets or when the hypr dir changes
              PathExistsGlob = [
                "%t/hypr/*/.socket.sock"
                "%t/hypr/*/.socket2.sock"
              ];
              DirectoryNotEmpty = "%t/hypr";
              PathChanged = "%t/hypr";
              Unit = "pyprland-watch.service";
            };
          }
          (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];})
        ];
      }))
  ]
