{
  pkgs,
  lib,
  config,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    home.packages = with pkgs; config.lib.neg.pkgsList [
      fastfetch # modern, fast system fetch
      onefetch # repository summary in terminal
    ];
  }
  # Link static configuration directory to XDG config
  (xdg.mkXdgSource "fastfetch"
    (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/cli/fastfetch/conf" true))
]
