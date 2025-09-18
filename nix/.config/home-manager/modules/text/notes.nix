{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList (with pkgs; [
    zk # notes database
  ]);
}
