{ lib, pkgs, config, ... }:
with lib;
mkIf config.features.gui.enable (
  let
    rofiPkg = pkgs.rofi.override {
      plugins = [
        pkgs.rofi-file-browser
        pkgs.neg.rofi_games
      ];
    };
    tpl = builtins.readFile ../rofi/rofi-wrapper.sh;
    rendered = lib.replaceStrings ["@ROFI_BIN@" "@JQ_BIN@" "@HYPRCTL_BIN@"] [ (lib.getExe rofiPkg) (lib.getExe pkgs.jq) (lib.getExe' pkgs.hyprland "hyprctl") ] tpl;
    rofiWrapper = pkgs.writeShellApplication {
      name = "rofi-wrapper";
      runtimeInputs = [ pkgs.gawk pkgs.gnused ];
      text = rendered;
    };
  in
    config.lib.neg.mkLocalBin "rofi" ''#!/usr/bin/env bash
      set -euo pipefail
      exec ${rofiWrapper}/bin/rofi-wrapper "$@"''
)

