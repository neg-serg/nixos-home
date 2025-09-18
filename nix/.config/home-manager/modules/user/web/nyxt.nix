{ lib, pkgs, config, ... }:
with lib;
  mkIf (config.features.web.enable && config.features.web.nyxt.enable) (let
    nyxtPkg = pkgs.nyxt;
    dlDir = "${config.home.homeDirectory}/dw";
    xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
  in lib.mkMerge [
    { home.packages = config.lib.neg.pkgsList [nyxtPkg]; }
    (let
       tpl = builtins.readFile ./nyxt/init.lisp;
       rendered = lib.replaceStrings ["@DL_DIR@"] [ dlDir ] tpl;
     in xdg.mkXdgText "nyxt/init.lisp" rendered)
  ]
