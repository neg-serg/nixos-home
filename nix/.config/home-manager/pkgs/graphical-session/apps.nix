{
  pkgs,
  ...
}:
with {
  clipboard-sync = pkgs.callPackage ../../packages/clipboard-sync {};
}; {
  home.packages = with pkgs; [
    activitywatch # track your activity on pc
    autocutsel
    clipcat
    clipboard-jh
    clipboard-sync
  ];
}
