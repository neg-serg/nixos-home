{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.user.services.playerctld = lib.recursiveUpdate {
    Unit.Description = "Keep track of media player activity";
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.playerctl "playerctld"} daemon";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["defaultWanted"];});
}
