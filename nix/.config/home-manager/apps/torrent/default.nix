{ pkgs, stable, ... }: {
  home.packages = with pkgs; [
      stable.stig # transmission client
      transmission # bittorrent daemon
  ];

  systemd.user.services.transmission-daemon = {
      Unit = {
          Description = "transmission service";
          After = ["network.target"];
          ConditionPathExists = "${pkgs.transmission}/bin/transmission-daemon";
      };
      Service = {
          Type = "notify";
          ExecStart = "${pkgs.transmission}/bin/transmission-daemon -g %E/transmission-daemon -f --log-error";
          Restart = "on-failure";
          RestartSec = "30";
          StartLimitBurst = "8";
          ExecReload = "${pkgs.util-linux}/bin/kill -s HUP $MAINPID";
      };
      Install = { WantedBy = ["default.target"]; };
  };

}
