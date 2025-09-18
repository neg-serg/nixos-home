{ pkgs, lib, config, ... }:
  (config.lib.neg.systemdUser.mkSimpleService {
    name = "playerctld";
    description = "Keep track of media player activity";
    execStart = "${lib.getExe' pkgs.playerctl "playerctld"} daemon";
    presets = ["defaultWanted"];
    serviceExtra = { Type = "oneshot"; };
  })

