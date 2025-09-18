{lib, config, ...}:
with lib; {
  imports =
    [ ]
    ++ lib.optionals (config.features.media.audio.apps.enable or false) [
      ./apps.nix
      ./beets.nix
      ./ncpamixer.nix
    ]
    ++ lib.optionals (config.features.media.audio.mpd.enable or false) [
      ./mpd
      ./rmpc.nix
    ]
    ++ lib.optionals (config.features.media.audio.core.enable or false) [
      ./core.nix
    ]
    ++ lib.optionals (config.features.media.audio.creation.enable or false) [
      ./creation.nix
    ];
}
