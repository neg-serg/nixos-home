{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    activitywatch # track your activity on pc
    autocutsel # tool to sync x11 buffers
    clipboard-jh # platform independent clipboard manager, test it more later
    clipcat # replacement for gpaste
  ];
}
