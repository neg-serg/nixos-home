{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList (with pkgs; [
    # fontforge # font processing
    pango # for pango-list
  ]);
}
