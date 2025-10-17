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
    pkgs.exiftool # read/write EXIF metadata
    pkgs.exiv2 # manage image metadata (EXIF/IPTC/XMP)
    pkgs.mediainfo # show media file metadata (audio/video/images)
    # editors
    pkgs.gimp # raster image editor
    pkgs.rawtherapee # RAW photo editor
    pkgs.graphviz # graph visualization (render dot files)
    # optimizers
    pkgs.jpegoptim # optimize/compress JPEG files
    pkgs.optipng # optimize PNG files
    pkgs.pngquant # lossy PNG compression/quantization
    pkgs.advancecomp # recompress ZIP/PNG streams
    pkgs.scour # optimize/clean SVG files
    # color
    pkgs.pastel # color utilities (picker, convert, mix)
    pkgs.lutgen # generate LUTs and color gradients
    # qr
    pkgs.qrencode # generate QR codes
    pkgs.zbar # scan/read barcodes and QR codes
    # viewers
    pkgs.swayimg # Wayland image viewer
    swayimg-first # wrapper: open and jump to first image
    pkgs.viu # terminal image viewer
  ];
  }
  # Replace ad-hoc ~/.local/bin files with guarded wrappers
  {
    home.file.".local/bin/swayimg" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        exec ${swayimg-first}/bin/swayimg-first "$@"'';
    };
  }
  # Live-editable Swayimg config via helper (guards parent dir and target)
  (xdg.mkXdgSource "swayimg" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/media/images/swayimg/conf";
    recursive = true;
  })
])
