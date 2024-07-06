{pkgs, ...}: {
  systemd.user.services.vdirsyncer = {
    Unit = {Description = "Vdirsyncer synchronization service";};
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.vdirsyncer}/bin/vdirsyncer metasync";
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    };
  };

  systemd.user.timers.vdirsyncer = {
    Unit = {Description = "Vdirsyncer synchronization timer";};
    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "5m";
      Unit = "vdirsyncer.service";
    };
    Install = {WantedBy = ["timers.target"];};
  };
}
