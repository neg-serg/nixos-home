{ lib, config, pkgs, xdg, ... }:
let
  
in lib.mkMerge [
  {
  # Install gdb and manage its config under XDG
  home.packages = config.lib.neg.pkgsList [pkgs.gdb];
  }
  (xdg.mkXdgText "gdb/gdbinit" (builtins.readFile ./gdbinit))
]
