{ lib, config, pkgs, xdg, ... }:
let
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
  home.file.".local/bin/sx" = { executable = true; source = ./sx.sh; };
  home.file.".local/bin/sxivnc" = { executable = true; source = ./sxivnc.sh; };
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
