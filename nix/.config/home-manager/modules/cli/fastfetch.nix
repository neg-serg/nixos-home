{ pkgs, lib, config, ... }:
let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    home.packages = with pkgs; config.lib.neg.pkgsList [
      fastfetch # modern, fast system fetch
      onefetch # repository summary in terminal
    ];
  }
  # Link static configuration directory (config.jsonc + skull) from repo
  (xdg.mkXdgSource "fastfetch" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/cli/fastfetch/conf";
    recursive = true;
  })
]
