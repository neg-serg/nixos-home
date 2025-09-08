{ pkgs, lib, config, ... }:
with lib; {
  options.features.emulators.retroarch.full = mkEnableOption "use retroarchFull with extended (unfree) cores" // { default = true; };

  config = {
    home.packages = with pkgs;
      [
        pcem # emulator for ibm pc and clones
        pcsx2 # ps2 emulator
      ]
      ++ (if config.features.emulators.retroarch.full then [retroarchFull] else [retroarch]);
  };
}
