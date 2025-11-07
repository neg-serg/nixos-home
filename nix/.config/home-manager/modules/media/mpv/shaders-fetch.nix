{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.media.aiUpscale or {};
in
mkIf (config.features.gui.enable or false) (
  mkMerge [
    # Silence activation: do not fetch shaders during Home Manager activation.
    # Users can manage shaders manually or via their own scripts.
    (mkIf (cfg.enable or false) {})
  ])
