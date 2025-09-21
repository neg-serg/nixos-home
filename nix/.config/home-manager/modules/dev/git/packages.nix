{ lib, pkgs, config, ... }:
with lib;
mkIf config.features.dev.enable {
  home.packages = config.lib.neg.pkgsList [
    pkgs.act
    pkgs.difftastic
    pkgs.gh
    pkgs.gist
  ];
}

