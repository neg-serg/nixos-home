{pkgs, stable, ...}: {
  home.packages = with pkgs; [
    autocutsel # tool to sync x11 buffers
    clipboard-jh # platform independent clipboard manager, test it more later
    espanso # systemwide expander for keyboard
  ];
  systemd.user.services = {
    clipcat = {
      # replacement for gpaste
      Unit = {
        Description = "Clipcat daemon";
        PartOf = ["graphical-session.target"];
      };

      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/clipcat/grpc.sock";
        ExecStart = "${stable.clipcat}/bin/clipcatd --no-daemon --replace";
        Restart = "on-failure";
        Type = "simple";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };
  };
}
