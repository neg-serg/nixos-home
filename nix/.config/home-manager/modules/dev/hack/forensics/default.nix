{ pkgs, lib, config, ... }:
let
  inherit (lib) optionals;
  groups = with pkgs; rec {
    fs = [ ddrescue ext4magic extundelete sleuthkit ];
    stego = [ outguess steghide stegseek stegsolve zsteg ];
    analysis = [ ghidra-bin binwalk capstone volatility3 pdf-parser ];
    network = [ p0f ];
  };
in {
  home.packages =
    (optionals config.features.dev.hack.forensics.fs groups.fs)
    ++ (optionals config.features.dev.hack.forensics.stego groups.stego)
    ++ (optionals config.features.dev.hack.forensics.analysis groups.analysis)
    ++ (optionals config.features.dev.hack.forensics.network groups.network);
}
