{ pkgs, lib, config, ... }:
with lib; {
  systemd.user.services.playerctld = {
    Unit = {
      Description = "Keep track of media player activity";
    };
    Install.WantedBy = ["default.target"];
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.playerctl "playerctld"} daemon";
    };
  };
}
