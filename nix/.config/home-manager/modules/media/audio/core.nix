{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.core.enable (
  {
    home.packages = config.lib.neg.pkgsList (with pkgs; [
      # utils
      alsa-utils coppwr pw-volume pwvucontrol
      # routers
      helvum qpwgraph open-music-kontrollers.patchmatrix
    ]);
  }
)
