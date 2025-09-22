{ lib, pkgs, config, ... }:
with lib;
mkIf config.features.gui.enable (
  let
    rofiPkg = pkgs.rofi.override {
      plugins = [
        pkgs.rofi-file-browser # file browser mode for rofi
        pkgs.neg.rofi_games # custom games menu plugin
      ];
    };
    tpl = builtins.readFile ../rofi/rofi-wrapper.sh;
    rendered = lib.replaceStrings ["@ROFI_BIN@" "@JQ_BIN@" "@HYPRCTL_BIN@"] [ (lib.getExe rofiPkg) (lib.getExe pkgs.jq) (lib.getExe' pkgs.hyprland "hyprctl") ] tpl;
    rofiWrapper = pkgs.writeShellApplication {
      name = "rofi-wrapper";
      runtimeInputs = [
        pkgs.gawk # awk for simple text processing
        pkgs.gnused # sed for stream editing
      ];
      text = rendered;
    };
  in
    {
      home.file.".local/bin/rofi" = {
        executable = true;
        force = true;
        text = ''#!/usr/bin/env bash
          set -euo pipefail
          exec ${rofiWrapper}/bin/rofi-wrapper "$@"'';
      };
    }
)
