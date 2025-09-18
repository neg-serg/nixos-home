{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList (with pkgs; [
    evhz # show mouse refresh rate
    openrgb # manage rgb highlight
  ]);
}
