{ config, lib, pkgs, ... }:
lib.mkIf (config.features.gui.enable or false) {
  programs.mpv.scripts = [
    pkgs.mpvScripts.cutter
    pkgs.mpvScripts.mpris
    pkgs.mpvScripts.quality-menu
    pkgs.mpvScripts.seekTo
    pkgs.mpvScripts.sponsorblock
    pkgs.mpvScripts.thumbfast
    pkgs.mpvScripts.uosc
  ];
}

