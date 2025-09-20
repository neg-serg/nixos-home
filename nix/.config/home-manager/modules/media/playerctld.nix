{ pkgs, lib, config, ... }:
with lib;
mkIf (config.features.media.audio.apps.enable or false)
  (config.lib.neg.systemdUser.mkSimpleService {
    name = "playerctld";
    description = "Keep track of media player activity";
    execStart = "${lib.getExe' pkgs.playerctl "playerctld"} daemon";
    presets = ["defaultWanted"];
    serviceExtra = { Type = "oneshot"; };
  })

