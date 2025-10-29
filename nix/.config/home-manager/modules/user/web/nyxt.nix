{
  lib,
  pkgs,
  config,
  xdg,
  ...
}:
with lib;
  mkIf (config.features.web.enable && config.features.web.nyxt.enable) (let
    nyxtPkg = pkgs.nyxt;
    dlDir = "${config.home.homeDirectory}/dw";
  in
    lib.mkMerge [
      {
        home.packages = config.lib.neg.pkgsList [
          nyxtPkg # Nyxt web browser
        ];
      }
      (let
        tpl = builtins.readFile ./nyxt/init.lisp;
        rendered = lib.replaceStrings ["@DL_DIR@"] [dlDir] tpl;
      in
        xdg.mkXdgText "nyxt/init.lisp" rendered)
    ])
