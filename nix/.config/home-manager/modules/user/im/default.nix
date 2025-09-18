{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList (with pkgs; [
    tdl # Telegram CLI downloader/uploader
    telegram-desktop # cloud-based IM client
    vesktop # alternative Discord client
  ]);
}
