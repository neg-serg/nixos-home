{ lib, pkgs, config, ... }:
with lib;
lib.mkMerge [
  {
    # Install the library + CLI (ppinfo)
    home.packages = config.lib.neg.pkgsList [
      pkgs.neg.pretty_printer # pretty-printer library + ppinfo CLI
    ];
  }
  {
    # Clean up legacy script from ~/bin if it exists as a regular file
    home.activation.removeLegacyPrettyPrinter = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      legacy="$HOME/bin/pretty_printer.py"
      if [ -e "$legacy" ] && [ ! -L "$HOME/bin" ]; then
        rm -f "$legacy" || true
      fi
    '';
  }
]

