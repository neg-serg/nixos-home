{ lib, config, pkgs, xdg, ... }:
with lib;
mkIf (config.features.gui.enable or false) (
let
  # Wrapper: start swayimg, export SWAYIMG_IPC, jump to first image via IPC.
  swayimg-first = pkgs.writeShellScriptBin "swayimg-first" (
    let
      tpl = builtins.readFile ./swayimg-first.sh;
      text = lib.replaceStrings ["@SWAYIMG_BIN@" "@SOCAT_BIN@"] [ (lib.getExe pkgs.swayimg) (lib.getExe pkgs.socat) ] tpl;
    in text
  );
in lib.mkMerge [
  {
  home.packages = config.lib.neg.pkgsList [
    # metadata
    pkgs.exiftool pkgs.exiv2 pkgs.mediainfo
    # editors
    pkgs.gimp pkgs.rawtherapee pkgs.graphviz
    # optimizers
    pkgs.jpegoptim pkgs.optipng pkgs.pngquant pkgs.advancecomp pkgs.scour
    # color
    pkgs.pastel pkgs.lutgen
    # qr
    pkgs.qrencode pkgs.zbar
    # viewers
    pkgs.swayimg swayimg-first pkgs.viu
  ];
  }
  # Replace ad-hoc ~/.local/bin files with guarded wrappers
  (config.lib.neg.mkLocalBin "swayimg" ''#!/usr/bin/env bash
    set -euo pipefail
    exec ${swayimg-first}/bin/swayimg-first "$@"'')
  # Live-editable Swayimg config via helper (guards parent dir and target)
  (xdg.mkXdgSource "swayimg" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/media/images/swayimg/conf";
    recursive = true;
  })
])
