{ lib, config, ... }:
with lib;
mkIf (config.features.gui.enable or false) (lib.mkMerge [
  # Centralize simple local wrappers under ~/.local/bin
  (config.lib.neg.mkLocalBin "sx" (builtins.readFile ../../media/images/sx.sh))
  (config.lib.neg.mkLocalBin "sxivnc" (builtins.readFile ../../media/images/sxivnc.sh))
])

