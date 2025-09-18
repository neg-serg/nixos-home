{ lib, config, pkgs, xdg ? import ../../lib/xdg-helpers.nix { inherit lib; }, ... }:
with lib;
  mkIf config.features.gui.enable (lib.mkMerge [
    {
      home.packages = config.lib.neg.pkgsList [pkgs.walker];
    }
    # Link entire conf directory (as before): config.toml + themes/*
    (xdg.mkXdgSource "walker" {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/walker/conf";
      recursive = true;
    })
  ])
