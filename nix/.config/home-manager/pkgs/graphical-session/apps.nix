{
  pkgs,
  stable,
  ...
}:
{
  home.packages = with pkgs; [
    autocutsel # tool to sync x11 buffers
    clipboard-jh # platform independent clipboard manager, test it more later
    stable.clipcat # replacement for gpaste
  ];
}
