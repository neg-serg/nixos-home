{pkgs, ...}: {
  home.packages = with pkgs; [
    zk # notes database
  ];
}
