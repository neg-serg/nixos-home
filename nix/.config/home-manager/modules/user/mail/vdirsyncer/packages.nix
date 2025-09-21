{ lib, pkgs, config, ... }:
with lib;
mkIf (config.features.mail.enable && config.features.mail.vdirsyncer.enable) {
  home.packages = config.lib.neg.pkgsList [
    pkgs.vdirsyncer
  ];
}

