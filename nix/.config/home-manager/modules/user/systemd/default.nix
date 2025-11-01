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
