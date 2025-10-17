{ lib, config, pkgs, ... }:
with lib;
let
  scriptText = builtins.readFile ./local-bin/scripts/autoclick-toggle;
in
mkIf (config.features.gui.enable or false) {
  home.packages = config.lib.neg.pkgsList [ pkgs.ydotool ];

  home.file.".local/bin/autoclick-toggle" = {
    executable = true;
    force = true;
    text = scriptText;
  };

  systemd.user.services.ydotoold =
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
}
