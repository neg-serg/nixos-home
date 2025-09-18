{ pkgs, lib, config, ... }:
let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib pkgs; };
in lib.mkMerge [
  {
    home.packages = config.lib.neg.pkgsList [pkgs.handlr];
  }
  (xdg.mkXdgConfigToml "handlr/handlr.toml" {
    enable_selector = false;
    selector = "rofi -dmenu -p 'Open With: '";
  })
]
