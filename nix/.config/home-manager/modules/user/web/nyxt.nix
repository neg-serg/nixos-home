{
  lib,
  pkgs,
  config,
  xdg,
  nyxt4 ? null,
  ...
}:
with lib;
  mkIf (config.features.web.enable && config.features.web.nyxt.enable) (let
    # Prefer Nyxt 4 / QtWebEngine backend when provided via specialArgs (e.g., from chaotic)
    nyxtPkg = if nyxt4 != null then nyxt4 else pkgs.nyxt;
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
