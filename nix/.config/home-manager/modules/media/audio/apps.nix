{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.apps.enable (
  {
  home.packages = config.lib.neg.pkgsList (with pkgs; [
      # codecs / ripping / players
      ape cdparanoia cider
      # analysis
      dr14_tmeter essentia-extractor opensoundmeter sonic-visualiser roomeqwizard
      # tagging
      id3v2 picard unflac
      # cli
      ncpamixer sox
      # net
      nicotine-plus scdl streamlink
      # misc
      screenkey
  ]);
  }
)
