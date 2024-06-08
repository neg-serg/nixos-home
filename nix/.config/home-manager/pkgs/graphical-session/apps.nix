{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    activitywatch # track your activity on pc
    autocutsel
    clipcat
    clipboard-jh
  ];
}
