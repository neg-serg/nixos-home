{ lib, pkgs, config, ... }:
with lib;
mkIf (config.features.mail.enable && config.features.mail.vdirsyncer.enable) {
  systemd.user.services.vdirsyncer = lib.mkMerge [
    {
      Unit = { Description = "Vdirsyncer synchronization service"; };
      Service = {
        Type = "oneshot";
        ExecStartPre = let exe = lib.getExe pkgs.vdirsyncer; in "${exe} metasync";
        ExecStart = let exe = lib.getExe pkgs.vdirsyncer; in "${exe} sync";
      };
    }
    (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["netOnline"]; })
  ];
}

