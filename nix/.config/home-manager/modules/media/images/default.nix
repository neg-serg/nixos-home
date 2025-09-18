{ lib, config, pkgs, ... }:
let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
  # Wrapper: start swayimg, export SWAYIMG_IPC, jump to first image via IPC.
  swayimg-first = pkgs.writeShellScriptBin "swayimg-first" (
    let
      tpl = builtins.readFile ./swayimg-first.sh;
      text = lib.replaceStrings ["@SWAYIMG_BIN@" "@SOCAT_BIN@"] [ (lib.getExe pkgs.swayimg) (lib.getExe pkgs.socat) ] tpl;
    in text
  );
  # Package selection kept simple: apply global exclude filter only.
in lib.mkMerge [
  {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    # metadata
    exiftool exiv2 mediainfo
    # editors
    gimp rawtherapee graphviz
    # optimizers
    jpegoptim optipng pngquant advancecomp scour
    # color
    pastel lutgen
    # qr
    qrencode zbar
    # viewers
    swayimg swayimg-first viu
  ];
  }
  {
  home.file.".local/bin/swayimg".source = "${swayimg-first}/bin/swayimg-first";
  home.file.".local/bin/sx" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      exec swayimg-first "$@"
    '';
  };
  home.file.".local/bin/sxivnc".text = ''
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v nsxiv >/dev/null 2>&1; then
      exec nsxiv -n -c "$@"
    elif command -v sxiv >/dev/null 2>&1; then
      exec sxiv -n -c "$@"
    elif command -v swayimg >/dev/null 2>&1; then
      exec swayimg "$@"
    else
      echo "sxivnc: no nsxiv/sxiv/swayimg in PATH" >&2
      exit 127
    fi
  '';
  }

  # Guard: ensure we don't write through an unexpected symlink or file at ~/.local/bin/swayimg
  # Collapse to a single step that removes any pre-existing file/dir/symlink.
  # Prepared via global prepareUserPaths action

  # Live-editable Swayimg config via helper (guards parent dir and target)
  (xdg.mkXdgSource "swayimg" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/media/images/swayimg/conf";
    recursive = true;
  })
]
