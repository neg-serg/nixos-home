{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    activitywatch # track your activity on pc
  ];

  systemd.user.services."org.gnome.GPaste" = {
    Unit = {
      Description = "GPaste daemon";
      PartOf=["graphical-session.target"];
      After=["graphical-session.target"];
    };
    Service = {
      Type = "dbus";
      BusName = "org.gnome.GPaste";
      ExecStart = "${pkgs.gnome.gpaste}/libexec/gpaste/gpaste-daemon";
    };
    Install = {WantedBy = ["graphical-session.target"];};
  };
}
