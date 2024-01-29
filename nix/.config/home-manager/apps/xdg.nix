{ config, pkgs, ... }: {
  home.packages = with pkgs; [
      handlr # xdg-open
      xdg-ninja # autodetect stuff that should be moved from HOME dir
  ];
}
