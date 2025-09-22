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
  {
    # Wrapper to ensure legacy ~/bin/vid-info can import pretty_printer from the packaged lib
    home.activation.cleanBin_vid_info = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      p="$HOME/.local/bin/vid-info"
      if [ -e "$p" ] && [ ! -L "$p" ]; then
        if [ -d "$p" ]; then rm -rf "$p"; else rm -f "$p"; fi
      fi
    '';
    home.file.".local/bin/vid-info" = {
      executable = true;
      text = ''#!/usr/bin/env python3
import argparse
import os
from neg_pretty_printer import FileInfoPrinter

def main() -> None:
    p = argparse.ArgumentParser(prog='vid-info', description='Pretty print file/dir info')
    p.add_argument('paths', nargs='*', help='Paths to print info for')
    args = p.parse_args()

    if not args.paths:
        FileInfoPrinter.currentdir(os.getcwd())
        return

    for path in args.paths:
        if os.path.isdir(path):
            FileInfoPrinter.dir(path)
        elif os.path.exists(path):
            FileInfoPrinter.existsfile(path)
        else:
            FileInfoPrinter.nonexistsfile(path)

if __name__ == '__main__':
    main()
'';
    };
  }
])
