{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
mkIf (config.features.gui.enable or false) (
  mkIf (config.features.media.aiUpscale.enable or false) (
    {
      # Use mpv package built with VapourSynth filter and provide Python path
      programs.mpv.package = pkgs.neg.mpv-vs;
      home.packages = [ pkgs.vapoursynth pkgs.python3Packages.vapoursynth ];
    }
  )
)

