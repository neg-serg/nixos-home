{ lib, config, ... }:
with lib;
mkIf (config.features.gui.enable or false) (lib.mkMerge [
  # Centralize simple local wrappers under ~/.local/bin, inline to avoid early config.lib recursion in hm‑eval
  {
    home.activation.cleanBin_sx = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      p="$HOME/.local/bin/sx"
      if [ -e "$p" ] && [ ! -L "$p" ]; then
        if [ -d "$p" ]; then rm -rf "$p"; else rm -f "$p"; fi
      fi
    '';
    home.file.".local/bin/sx" = {
      executable = true;
      text = (builtins.readFile ../../media/images/sx.sh);
    };
  }
  {
    home.activation.cleanBin_sxivnc = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      p="$HOME/.local/bin/sxivnc"
      if [ -e "$p" ] && [ ! -L "$p" ]; then
        if [ -d "$p" ]; then rm -rf "$p"; else rm -f "$p"; fi
      fi
    '';
    home.file.".local/bin/sxivnc" = {
      executable = true;
      text = (builtins.readFile ../../media/images/sxivnc.sh);
    };
  }
])
