{ pkgs, lib, config, ... }:
with lib; {
  systemd.user.services.playerctld = lib.mkMerge [
    {
    Unit = {
      Description = "Keep track of media player activity";
    };
    Install.WantedBy = ["default.target"];
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.playerctl "playerctld"} daemon";
    };
    }
    (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; })
  ];
}
