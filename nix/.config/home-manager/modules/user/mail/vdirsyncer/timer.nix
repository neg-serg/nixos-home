{
  lib,
  config,
  ...
}:
with lib;
  mkIf (config.features.mail.enable && config.features.mail.vdirsyncer.enable) {
    systemd.user.timers.vdirsyncer = lib.mkMerge [
      {
        Unit = {Description = "Vdirsyncer synchronization timer";};
        Timer = {
          OnBootSec = "2m";
          OnUnitActiveSec = "5m";
          Unit = "vdirsyncer.service";
        };
      }
      (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["timers"];})
    ];
  }
