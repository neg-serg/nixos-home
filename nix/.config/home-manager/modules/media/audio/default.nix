{ lib, config, ... }:
with lib; {
  options.features.media.audio = {
    core.enable = mkEnableOption "enable audio core (PipeWire routing tools)" // { default = true; };
    apps.enable = mkEnableOption "enable audio apps (players, tools)" // { default = true; };
    creation.enable = mkEnableOption "enable audio creation stack (DAW, synths)" // { default = true; };
    mpd.enable = mkEnableOption "enable MPD stack (mpd, clients, mpdris2)" // { default = true; };
  };

  imports = [
    ./apps.nix
    ./beets.nix
    ./core.nix
    ./creation.nix
    ./mpd
  ];
}
