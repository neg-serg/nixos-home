{ config, pkgs, stable, ... }: {
  home.packages = with pkgs; [
      stable.stig # transmission client
      transmission # bittorrent daemon
  ];
}
