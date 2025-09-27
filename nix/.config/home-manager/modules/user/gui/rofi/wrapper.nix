{ lib, pkgs, config, ... }:
with lib;
mkIf config.features.gui.enable (
  let
    tpl = builtins.readFile ../rofi/rofi-wrapper.sh;
    rendered = lib.replaceStrings ["@ROFI_BIN@" "@JQ_BIN@" "@HYPRCTL_BIN@"] [ (lib.getExe config.neg.rofi.package) (lib.getExe pkgs.jq) (lib.getExe' pkgs.hyprland "hyprctl") ] tpl;
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
      # Optional helper to try pass in two columns without overriding system rofi-pass
      home.file.".local/bin/rofi-pass-2col" = {
        executable = true;
        force = true;
        text = ''#!/usr/bin/env bash
          set -euo pipefail
          exec ${rofiWrapper}/bin/rofi-wrapper \
            -modi "pass:${lib.getExe pkgs.rofi-pass-wayland} -m" \
            -show pass \
            -theme pass \
            -columns 2 \
            -p 'pass ❯>' "$@"'';
      };
    }
)
