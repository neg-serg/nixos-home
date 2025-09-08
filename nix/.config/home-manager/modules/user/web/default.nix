{ lib, config, ... }:
with lib; {
  options.features.web = {
    enable = mkEnableOption "enable Web stack (browsers + tools)" // { default = true; };
    floorp.enable = mkEnableOption "enable Floorp browser" // { default = true; };
    yandex.enable = mkEnableOption "enable Yandex browser" // { default = true; };
    tools.enable = mkEnableOption "enable web tools (aria2, yt-dlp, misc)" // { default = true; };
  };

  imports = [
    ./aria.nix
    ./browsing.nix
    ./misc.nix
    ./yt-dlp # download from youtube and another sources
  ];
}
