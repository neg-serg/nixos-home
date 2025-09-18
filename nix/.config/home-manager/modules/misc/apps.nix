{ config, pkgs, ... }: {
  home.packages = config.lib.neg.pkgsList (with pkgs; [
    blesh # bluetooth shell
    pwgen # generate passwords
  ]);
}
