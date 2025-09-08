{ pkgs, lib, config, ... }:
with lib; {
  config = {
    home.packages = with pkgs;
      [
        pcem # emulator for ibm pc and clones
        pcsx2 # ps2 emulator
      ]
      ++ (if config.features.emulators.retroarch.full then [retroarchFull] else [retroarch]);
  };
}
