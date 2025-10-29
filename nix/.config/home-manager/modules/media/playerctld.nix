{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
  mkIf (config.features.media.audio.apps.enable or false) {
    systemd.user.services.playerctld = lib.mkMerge [
      {
        Unit = {Description = "Keep track of media player activity";};
        Service = {
          Type = "oneshot";
          ExecStart = let
            exe = lib.getExe' pkgs.playerctl "playerctld";
            args = ["daemon"];
          in "${exe} ${lib.escapeShellArgs args}";
        };
      }
      (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["defaultWanted"];})
    ];
  }
