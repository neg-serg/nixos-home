{ config, lib, ... }:
with lib; {
  imports =
    [
      ./apps.nix
      ./audio
    ]
    ++ lib.optionals (config.features.gui.enable or false) [
      ./images
      ./mpv.nix
      ./playerctld.nix
    ]
    ++ lib.optionals (config.features.media.audio.core.enable or false) [
      ./pipewire.nix
    ];
  # moved to playerctld.nix and pipewire.nix
}
